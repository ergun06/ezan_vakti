import 'package:flutter_test/flutter_test.dart';
import 'package:adhan/adhan.dart';

void main() {
  test('adhan prayer times verification', () {
    final coordinates = Coordinates(41.0082, 28.9784); // Istanbul
    final params = CalculationMethod.turkey.getParameters();
    params.madhab = Madhab.hanafi;
    final date = DateComponents.from(DateTime.now());
    final prayerTimes = PrayerTimes(coordinates, date, params);

    expect(prayerTimes.fajr, isNotNull);
    expect(prayerTimes.sunrise, isNotNull);
    expect(prayerTimes.dhuhr, isNotNull);
    expect(prayerTimes.asr, isNotNull);
    expect(prayerTimes.maghrib, isNotNull);
    expect(prayerTimes.isha, isNotNull);

    final qiblaDirection = Qibla(coordinates).direction;
    expect(qiblaDirection, greaterThan(140.0));
  });
}
