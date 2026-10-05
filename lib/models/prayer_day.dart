import 'package:intl/intl.dart';

enum PrayerType {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha,
  none,
}

extension PrayerTypeExtension on PrayerType {
  String get turkishName {
    switch (this) {
      case PrayerType.fajr:
        return 'İmsak';
      case PrayerType.sunrise:
        return 'Güneş';
      case PrayerType.dhuhr:
        return 'Öğle';
      case PrayerType.asr:
        return 'İkindi';
      case PrayerType.maghrib:
        return 'Akşam';
      case PrayerType.isha:
        return 'Yatsı';
      case PrayerType.none:
        return 'Vakit Yok';
    }
  }

  String get arabicName {
    switch (this) {
      case PrayerType.fajr:
        return 'الفجر';
      case PrayerType.sunrise:
        return 'الشروق';
      case PrayerType.dhuhr:
        return 'الظهر';
      case PrayerType.asr:
        return 'العصر';
      case PrayerType.maghrib:
        return 'المغرب';
      case PrayerType.isha:
        return 'العشاء';
      case PrayerType.none:
        return '';
    }
  }

  String get description {
    switch (this) {
      case PrayerType.fajr:
        return 'Sabah namazı vakti girişi ve oruç başlangıcı';
      case PrayerType.sunrise:
        return 'Güneşin doğuş vakti';
      case PrayerType.dhuhr:
        return 'Güneşin tepe noktasını geçmesiyle başlar';
      case PrayerType.asr:
        return 'Gölgenin uzamasıyla ikindi vakti başlar';
      case PrayerType.maghrib:
        return 'Güneşin batışı ve iftar vakti';
      case PrayerType.isha:
        return 'Günün son namaz vakti ve yatsı girişi';
      case PrayerType.none:
        return '';
    }
  }
}

class PrayerDay {
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final String hijriDate;

  PrayerDay({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.hijriDate,
  });

  DateTime getTimeForPrayer(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return fajr;
      case PrayerType.sunrise:
        return sunrise;
      case PrayerType.dhuhr:
        return dhuhr;
      case PrayerType.asr:
        return asr;
      case PrayerType.maghrib:
        return maghrib;
      case PrayerType.isha:
        return isha;
      case PrayerType.none:
        return fajr;
    }
  }

  String getFormattedTime(PrayerType type) {
    final t = getTimeForPrayer(type);
    return DateFormat('HH:mm').format(t);
  }

  PrayerType getCurrentPrayer(DateTime now) {
    if (now.isBefore(fajr)) return PrayerType.isha; // previous night's isha
    if (now.isBefore(sunrise)) return PrayerType.fajr;
    if (now.isBefore(dhuhr)) return PrayerType.sunrise;
    if (now.isBefore(asr)) return PrayerType.dhuhr;
    if (now.isBefore(maghrib)) return PrayerType.asr;
    if (now.isBefore(isha)) return PrayerType.maghrib;
    return PrayerType.isha;
  }

  PrayerType getNextPrayer(DateTime now) {
    if (now.isBefore(fajr)) return PrayerType.fajr;
    if (now.isBefore(sunrise)) return PrayerType.sunrise;
    if (now.isBefore(dhuhr)) return PrayerType.dhuhr;
    if (now.isBefore(asr)) return PrayerType.asr;
    if (now.isBefore(maghrib)) return PrayerType.maghrib;
    if (now.isBefore(isha)) return PrayerType.isha;
    return PrayerType.fajr; // next day fajr
  }

  DateTime getNextPrayerTime(DateTime now, DateTime tomorrowFajr) {
    final next = getNextPrayer(now);
    if (now.isAfter(isha)) {
      return tomorrowFajr;
    }
    return getTimeForPrayer(next);
  }

  Duration getTimeRemaining(DateTime now, DateTime tomorrowFajr) {
    final nextTime = getNextPrayerTime(now, tomorrowFajr);
    final diff = nextTime.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Calculates percentage of time elapsed in the current interval [0.0 - 1.0]
  double getProgress(DateTime now, DateTime tomorrowFajr) {
    DateTime start;
    DateTime end;

    if (now.isBefore(fajr)) {
      // Between yesterday's isha and today's fajr, approx
      return 0.5;
    } else if (now.isBefore(sunrise)) {
      start = fajr;
      end = sunrise;
    } else if (now.isBefore(dhuhr)) {
      start = sunrise;
      end = dhuhr;
    } else if (now.isBefore(asr)) {
      start = dhuhr;
      end = asr;
    } else if (now.isBefore(maghrib)) {
      start = asr;
      end = maghrib;
    } else if (now.isBefore(isha)) {
      start = maghrib;
      end = isha;
    } else {
      start = isha;
      end = tomorrowFajr;
    }

    final total = end.difference(start).inSeconds;
    if (total <= 0) return 0.0;
    final elapsed = now.difference(start).inSeconds;
    final ratio = elapsed / total;
    return ratio.clamp(0.0, 1.0);
  }

  /// Kerahat Vakti Tespiti
  /// 1. Güneş doğduktan sonra 45 dakika
  /// 2. Güneş tam tepedeyken (Öğleye 40-45 dk kala)
  /// 3. Akşama 45 dakika kala (Güneş batarken)
  String? getKerahatWarning(DateTime now) {
    // 1. Sabah kerahati: sunrise to sunrise + 45min
    final sunriseEnd = sunrise.add(const Duration(minutes: 45));
    if (now.isAfter(sunrise) && now.isBefore(sunriseEnd)) {
      final rem = sunriseEnd.difference(now).inMinutes;
      return 'Güneş Doğuşu Kerahat Vakti (Kalan: $rem dk). Farz ve nafile namaz kılınması mekruhtur.';
    }

    // 2. Öğle öncesi kerahet (istiva vakti): dhuhr - 40min to dhuhr
    final dhuhrStart = dhuhr.subtract(const Duration(minutes: 40));
    if (now.isAfter(dhuhrStart) && now.isBefore(dhuhr)) {
      final rem = dhuhr.difference(now).inMinutes;
      return 'Öğle Öncesi (İstiva) Kerahat Vakti (Kalan: $rem dk). Nafile namaz mekruhtur.';
    }

    // 3. Akşam öncesi kerahat (ısfirar): maghrib - 45min to maghrib
    final maghribStart = maghrib.subtract(const Duration(minutes: 45));
    if (now.isAfter(maghribStart) && now.isBefore(maghrib)) {
      final rem = maghrib.difference(now).inMinutes;
      return 'Güneş Batışı Kerahat Vakti (Kalan: $rem dk). Sadece o günün ikindi farzı kılınabilir.';
    }

    return null;
  }
}
