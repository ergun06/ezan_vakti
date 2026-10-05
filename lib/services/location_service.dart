import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/city.dart';

class LocationService {
  static final LocationService instance = LocationService._internal();
  LocationService._internal();

  Future<City?> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied.');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Find closest known city for display name
      City closest = allPredefinedCities.first;
      double minDistance = double.infinity;

      for (final city in allPredefinedCities) {
        final d = _calculateDistance(
          position.latitude,
          position.longitude,
          city.latitude,
          city.longitude,
        );
        if (d < minDistance) {
          minDistance = d;
          closest = city;
        }
      }

      String displayName;
      if (minDistance < 25) {
        displayName = '${closest.name} (Konumunuz)';
      } else if (minDistance < 80) {
        displayName = '${closest.name} Civarı (GPS)';
      } else {
        displayName = 'Mevcut Konum (${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)})';
      }

      return City(
        name: displayName,
        country: closest.country,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }
}
