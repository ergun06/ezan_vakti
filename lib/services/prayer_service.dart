import 'dart:math' as math;
import 'package:adhan/adhan.dart';
import '../models/city.dart';
import '../models/prayer_day.dart';

class DailyContent {
  final String ayahArabic;
  final String ayahTurkish;
  final String ayahSource;
  final String hadithArabic;
  final String hadithTurkish;
  final String hadithSource;

  const DailyContent({
    required this.ayahArabic,
    required this.ayahTurkish,
    required this.ayahSource,
    required this.hadithArabic,
    required this.hadithTurkish,
    required this.hadithSource,
  });
}

class PrayerService {
  static const double kaabaLat = 21.422487;
  static const double kaabaLng = 39.826206;

  static PrayerDay calculatePrayerDay(City city, DateTime date) {
    final coordinates = Coordinates(city.latitude, city.longitude);
    final params = CalculationMethod.turkey.getParameters();
    params.madhab = Madhab.hanafi;

    final dateComponents = DateComponents(date.year, date.month, date.day);
    final pt = PrayerTimes(coordinates, dateComponents, params);

    final hijriStr = getHijriDate(date);

    return PrayerDay(
      date: date,
      fajr: pt.fajr,
      sunrise: pt.sunrise,
      dhuhr: pt.dhuhr,
      asr: pt.asr,
      maghrib: pt.maghrib,
      isha: pt.isha,
      hijriDate: hijriStr,
    );
  }

  /// Calculates next day fajr to support midnight transitions smoothly
  static DateTime getTomorrowFajr(City city, DateTime date) {
    final tomorrow = date.add(const Duration(days: 1));
    final coordinates = Coordinates(city.latitude, city.longitude);
    final params = CalculationMethod.turkey.getParameters();
    params.madhab = Madhab.hanafi;
    final dateComponents = DateComponents(tomorrow.year, tomorrow.month, tomorrow.day);
    final pt = PrayerTimes(coordinates, dateComponents, params);
    return pt.fajr;
  }

  /// Generates a month of prayer days
  static List<PrayerDay> getMonthlyImsakiye(City city, int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final list = <PrayerDay>[];
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      list.add(calculatePrayerDay(city, date));
    }
    return list;
  }

  /// Returns Qibla direction in degrees [0-360]
  static double getQiblaDirection(City city) {
    final coords = Coordinates(city.latitude, city.longitude);
    return Qibla(coords).direction;
  }

  /// Calculates distance to Kaaba in kilometers
  static double getDistanceToKaaba(City city) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(kaabaLat - city.latitude);
    final dLon = _toRadians(kaabaLng - city.longitude);

    final lat1 = _toRadians(city.latitude);
    final lat2 = _toRadians(kaabaLat);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degree) => degree * math.pi / 180.0;

  /// Hijri date calculation based on standard tabular / civil conversion
  static String getHijriDate(DateTime date) {
    // Julian Day calculation
    int y = date.year;
    int m = date.month;
    int d = date.day;

    if (m < 3) {
      y -= 1;
      m += 12;
    }

    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    final jd = (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524.5;

    // Convert JD to Hijri
    final l = jd.floor() - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    final lRemainder = l - 10631 * n + 354;
    final j = ((10985 - lRemainder) / 5316).floor() *
            ((50 * lRemainder) / 17719).floor() +
        (lRemainder / 5670).floor() * ((43 * lRemainder) / 15238).floor();
    final lFinal = lRemainder -
        ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() +
        29;
    final hijriMonth = ((24 * lFinal) / 709).floor();
    final hijriDay = lFinal - ((709 * hijriMonth) / 24).floor();
    final hijriYear = 30 * n + j - 30;

    const islamicMonths = [
      'Muharrem',
      'Safer',
      'Rebiülevvel',
      'Rebiülahir',
      'Cemaziyelevvel',
      'Cemaziyelahir',
      'Recep',
      'Şaban',
      'Ramazan',
      'Şevval',
      'Zilkade',
      'Zilhicce',
    ];

    final monthIndex = (hijriMonth - 1).clamp(0, 11);
    final monthName = islamicMonths[monthIndex];
    return '$hijriDay $monthName $hijriYear H.';
  }

  /// Daily content (Ayat & Hadith) curated from reliable sources
  static DailyContent getDailyContent(DateTime date) {
    final dayOfYear = int.parse("${date.month}${date.day}");
    final index = dayOfYear % _contentList.length;
    return _contentList[index];
  }

  static final List<DailyContent> _contentList = [
    const DailyContent(
      ayahArabic: 'إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَوْقُوتًا',
      ayahTurkish: 'Şüphesiz namaz, mü’minlere vakitleri belirlenmiş bir farzdır.',
      ayahSource: 'Nisâ Suresi, 103. Ayet',
      hadithArabic: 'أَحَبُّ الْأَعْمَالِ إِلَى اللهِ الصَّلَاةُ لِوَقْتِهَا',
      hadithTurkish: 'Allah katında amellerin en sevimlisi, vaktinde kılınan namazdır.',
      hadithSource: 'Buhârî, Mevâkîtü’s-Salât 5',
    ),
    const DailyContent(
      ayahArabic: 'وَأَقِمِ الصَّلَاةَ طَرَفَيِ النَّهَارِ وَزُلَفًا مِنَ اللَّيْلِ ۚ إِنَّ الْحَسَنَاتِ يُذْهِبْنَ السَّيِّئَاتِ',
      ayahTurkish: 'Gündüzün iki ucunda ve gecenin gündüze yakın zamanlarında namaz kıl. Doğrusu iyilikler, kötülükleri giderir.',
      ayahSource: 'Hûd Suresi, 114. Ayet',
      hadithArabic: 'مَنْ غَدَا إِلَى الْمَسْجِدِ أَوْ رَاحَ، أَعَدَّ اللهُ لَهُ فِي الْجَنَّةِ نُزُلًا',
      hadithTurkish: 'Kim sabah veya akşam mescide giderse, Allah her gidiş gelişi için ona cennette bir konak hazırlar.',
      hadithSource: 'Müslim, Mesâcid 285',
    ),
    const DailyContent(
      ayahArabic: 'حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ وَقُومُوا لِلَّهِ قَانِتِينَ',
      ayahTurkish: 'Namazlara ve orta namaza (ikindiye) devam edin. Allah’a gönülden boyun eğerek divana durun.',
      ayahSource: 'Bakara Suresi, 238. Ayet',
      hadithArabic: 'مَنْ صَلَّى الْبَرْدَيْنِ دَخَلَ الْجَنَّةَ',
      hadithTurkish: 'İki serinlik namazını (sabah ve ikindiyi) kılan kimse cennete girer.',
      hadithSource: 'Buhârî, Mevâkît 17',
    ),
    const DailyContent(
      ayahArabic: 'وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ وَإِنَّهَا لَكَبِيرَةٌ إِلَّا عَلَى الْخَاشِعِينَ',
      ayahTurkish: 'Sabır ve namazla Allah’tan yardım isteyin. Şüphesiz namaz, huşû duyanlardan başkasına pek ağır gelir.',
      ayahSource: 'Bakara Suresi, 45. Ayet',
      hadithArabic: 'الصَّلَاةُ خَيْرُ مَوْضُوعٍ فَمَنِ اسْتَطَاعَ أَنْ يَسْتَكْثِرَ فَلْيَسْتَكْثِرْ',
      hadithTurkish: 'Namaz en hayırlı ibadettir; gücü yeten onu daha çok kılsın.',
      hadithSource: 'Taberânî, el-Mu’cemü’l-Evsat',
    ),
    const DailyContent(
      ayahArabic: 'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِنْ ذُرِّيَّتِي ۚ رَبَّنَا وَتَقَبَّلْ دُعَاءِ',
      ayahTurkish: 'Rabbim! Beni ve neslimi namazı dosdoğru kılanlardan eyle. Rabbimiz! Duamı kabul buyur.',
      ayahSource: 'İbrâhîm Suresi, 40. Ayet',
      hadithArabic: 'مِفْتَاحُ الْجَنَّةِ الصَّلَاةُ، وَمِفْتَاحُ الصَّلَاةِ الْوُضُوءُ',
      hadithTurkish: 'Cennetin anahtarı namaz, namazın anahtarı ise abdesttir.',
      hadithSource: 'Tirmizî, Tahâret 1',
    ),
  ];

  static const String ezanDuasiArabic =
      'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ الْقَائِمَةِ، آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ، وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ';

  static const String ezanDuasiTurkish =
      'Ey bu eksiksiz davetin ve kılınacak namazın Rabbi olan Allah’ım! Muhammed’e (s.a.v.) vesileyi ve fazileti ver. Onu vaad ettiğin Makam-ı Mahmud’a ulaştır.';
}
