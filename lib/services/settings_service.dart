import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/city.dart';
import '../models/prayer_day.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService instance = SettingsService._internal();
  SettingsService._internal();

  City _selectedCity = defaultCity;
  bool _fajrNotification = true;
  bool _sunriseNotification = false;
  bool _dhuhrNotification = true;
  bool _asrNotification = true;
  bool _maghribNotification = true;
  bool _ishaNotification = true;

  String _soundType = 'mekke'; // 'mekke', 'sabah', 'chime', 'silent'
  bool _autoPlaySound = true;
  int _advanceMinutes = 0; // 0 = exactly at prayer time, 15 = 15 min before, etc.
  double _volume = 0.8;
  String _themeMode = 'dark'; // 'dark', 'emerald', 'light'

  // Accessibility for Visually Impaired
  bool _speakAloudOnPrayer = true;
  bool _vibrateOnPrayer = true;
  bool _highContrast = false;

  City get selectedCity => _selectedCity;
  bool get fajrNotification => _fajrNotification;
  bool get sunriseNotification => _sunriseNotification;
  bool get dhuhrNotification => _dhuhrNotification;
  bool get asrNotification => _asrNotification;
  bool get maghribNotification => _maghribNotification;
  bool get ishaNotification => _ishaNotification;

  String get soundType => _soundType;
  bool get autoPlaySound => _autoPlaySound;
  int get advanceMinutes => _advanceMinutes;
  double get volume => _volume;
  String get themeMode => _themeMode;

  bool get speakAloudOnPrayer => _speakAloudOnPrayer;
  bool get vibrateOnPrayer => _vibrateOnPrayer;
  bool get highContrast => _highContrast;

  bool isNotificationEnabled(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return _fajrNotification;
      case PrayerType.sunrise:
        return _sunriseNotification;
      case PrayerType.dhuhr:
        return _dhuhrNotification;
      case PrayerType.asr:
        return _asrNotification;
      case PrayerType.maghrib:
        return _maghribNotification;
      case PrayerType.isha:
        return _ishaNotification;
      case PrayerType.none:
        return false;
    }
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final cityJson = prefs.getString('selected_city');
    if (cityJson != null) {
      try {
        _selectedCity = City.fromJson(jsonDecode(cityJson));
      } catch (e) {
        _selectedCity = defaultCity;
      }
    }

    _fajrNotification = prefs.getBool('fajr_notification') ?? true;
    _sunriseNotification = prefs.getBool('sunrise_notification') ?? false;
    _dhuhrNotification = prefs.getBool('dhuhr_notification') ?? true;
    _asrNotification = prefs.getBool('asr_notification') ?? true;
    _maghribNotification = prefs.getBool('maghrib_notification') ?? true;
    _ishaNotification = prefs.getBool('isha_notification') ?? true;

    _soundType = prefs.getString('sound_type') ?? 'mekke';
    _autoPlaySound = prefs.getBool('auto_play_sound') ?? true;
    _advanceMinutes = prefs.getInt('advance_minutes') ?? 0;
    _volume = prefs.getDouble('volume') ?? 0.8;
    _themeMode = prefs.getString('theme_mode') ?? 'dark';

    _speakAloudOnPrayer = prefs.getBool('speak_aloud_on_prayer') ?? true;
    _vibrateOnPrayer = prefs.getBool('vibrate_on_prayer') ?? true;
    _highContrast = prefs.getBool('high_contrast') ?? false;

    notifyListeners();
  }

  Future<void> setCity(City city) async {
    _selectedCity = city;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_city', jsonEncode(city.toJson()));
  }

  Future<void> toggleNotification(PrayerType type, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    switch (type) {
      case PrayerType.fajr:
        _fajrNotification = value;
        await prefs.setBool('fajr_notification', value);
        break;
      case PrayerType.sunrise:
        _sunriseNotification = value;
        await prefs.setBool('sunrise_notification', value);
        break;
      case PrayerType.dhuhr:
        _dhuhrNotification = value;
        await prefs.setBool('dhuhr_notification', value);
        break;
      case PrayerType.asr:
        _asrNotification = value;
        await prefs.setBool('asr_notification', value);
        break;
      case PrayerType.maghrib:
        _maghribNotification = value;
        await prefs.setBool('maghrib_notification', value);
        break;
      case PrayerType.isha:
        _ishaNotification = value;
        await prefs.setBool('isha_notification', value);
        break;
      case PrayerType.none:
        break;
    }
    notifyListeners();
  }

  Future<void> setSoundType(String type) async {
    _soundType = type;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sound_type', type);
  }

  Future<void> setAutoPlaySound(bool value) async {
    _autoPlaySound = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_play_sound', value);
  }

  Future<void> setAdvanceMinutes(int minutes) async {
    _advanceMinutes = minutes;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('advance_minutes', minutes);
  }

  Future<void> setVolume(double value) async {
    _volume = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', value);
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode);
  }

  Future<void> setSpeakAloudOnPrayer(bool value) async {
    _speakAloudOnPrayer = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('speak_aloud_on_prayer', value);
  }

  Future<void> setVibrateOnPrayer(bool value) async {
    _vibrateOnPrayer = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibrate_on_prayer', value);
  }

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast', value);
  }
}
