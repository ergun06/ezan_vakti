import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(const EzanVaktiApp());
}

class EzanVaktiApp extends StatelessWidget {
  const EzanVaktiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sesli Ezan Vakti',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const AnaSayfa(),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final FlutterTts flutterTts = FlutterTts();
  ShakeDetector? _shakeDetector;
  StreamSubscription<CompassEvent>? _compassAbonelik;

  Map<String, String> vakitler = {};
  String durumMesaji = 'Konum alınıyor, lütfen bekleyin...';
  bool yuklendi = false;

  // Kıble Değişkenleri
  double? _enlem;
  double? _boylam;
  double _kibleAcisi = 0.0;
  double _mevcutAci = 0.0;
  bool _kibleModuAcik = false;
  DateTime _sonKibleUyarisi = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ttsAyarla();
    _bildirimleriHazirla();
    _cevrimdisiVeriYukle();
    _konumVeVakitleriBaslat();
    _sallamaSensurunuBaslat();
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    _compassAbonelik?.cancel();
    super.dispose();
  }

  Future<void> _bildirimleriHazirla() async {
    const DarwinInitializationSettings iosAyarlari = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings ayarlar = InitializationSettings(iOS: iosAyarlari);
    await flutterLocalNotificationsPlugin.initialize(
      settings: ayarlar,
    );
  }

  void _sallamaSensurunuBaslat() {
    try {
      _shakeDetector = ShakeDetector.autoStart(
        onPhoneShake: (_) async {
          if (_kibleModuAcik) return;
          HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 150));
          HapticFeedback.heavyImpact();
          _siradakiVaktiOku();
        },
        shakeThresholdGravity: 1.5,
      );
    } catch (_) {}
  }

  Future<void> _ttsAyarla() async {
    await flutterTts.setLanguage('tr-TR');
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _seslendir(String metin) async {
    await flutterTts.stop();
    await flutterTts.speak(metin);
  }

  // --- Çevrimdışı (Offline) Depolama ---
  Future<void> _cevrimdisiVeriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final kayitliJson = prefs.getString('kayitli_vakitler');
    if (kayitliJson != null && vakitler.isEmpty) {
      final map = Map<String, String>.from(jsonDecode(kayitliJson));
      setState(() {
        vakitler = map;
        durumMesaji = 'Kayıtlı vakitler yüklendi (Çevrimdışı).';
        yuklendi = true;
      });
    }
  }

  Future<void> _cevrimdisiVeriKaydet(Map<String, String> veri) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kayitli_vakitler', jsonEncode(veri));
  }

  // --- Konum ve Vakit İşlemleri ---
  Future<void> _konumVeVakitleriBaslat() async {
    try {
      _seslendir('Konumunuz belirleniyor.');

      LocationPermission izin = await Geolocator.checkPermission();
      if (izin == LocationPermission.denied) {
        izin = await Geolocator.requestPermission();
        if (izin == LocationPermission.denied) {
          _varsayilanlaBaslat('Konum izni verilmedi. Varsayılan vakitler alınıyor.');
          return;
        }
      }

      if (izin == LocationPermission.deniedForever) {
        _varsayilanlaBaslat('Konum izni kapalı. Varsayılan vakitler alınıyor.');
        return;
      }

      Position konum = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      _enlem = konum.latitude;
      _boylam = konum.longitude;
      _kibleAcisiniHesapla(_enlem!, _boylam!);
      await _vakitleriCek(_enlem!, _boylam!);
    } catch (e) {
      _varsayilanlaBaslat('Konum tespit edilemedi. Varsayılan vakitler alınıyor.');
    }
  }

  void _varsayilanlaBaslat(String bildiri) async {
    _seslendir(bildiri);
    _enlem = 41.0267;
    _boylam = 37.5022;
    _kibleAcisiniHesapla(_enlem!, _boylam!);
    await _vakitleriCek(_enlem!, _boylam!);
  }

  void _kibleAcisiniHesapla(double lat, double lng) {
    const kabeLat = 21.422487;
    const kabeLng = 39.826206;

    final double phiK = kabeLat * math.pi / 180.0;
    final double lambdaK = kabeLng * math.pi / 180.0;
    final double phi = lat * math.pi / 180.0;
    final double lambda = lng * math.pi / 180.0;

    final double deltaL = lambdaK - lambda;
    final double y = math.sin(deltaL);
    final double x = math.cos(phi) * math.tan(phiK) - math.sin(phi) * math.cos(deltaL);

    double bearing = math.atan2(y, x) * 180.0 / math.pi;
    _kibleAcisi = (bearing + 360.0) % 360.0;
  }

  Future<void> _vakitleriCek(double enlem, double boylam) async {
    try {
      final bugun = DateTime.now();
      final tarihStr = DateFormat('dd-MM-yyyy').format(bugun);
      final adres = Uri.parse(
        'https://api.aladhan.com/v1/timings/$tarihStr?latitude=$enlem&longitude=$boylam&method=13',
      );

      final yanit = await http.get(adres);
      if (yanit.statusCode == 200) {
        final veri = jsonDecode(yanit.body)['data']['timings'];
        final cekilenVakitler = {
          'İmsak': veri['Fajr'].toString(),
          'Güneş': veri['Sunrise'].toString(),
          'Öğle': veri['Dhuhr'].toString(),
          'İkindi': veri['Asr'].toString(),
          'Akşam': veri['Maghrib'].toString(),
          'Yatsı': veri['Isha'].toString(),
        };

        setState(() {
          vakitler = cekilenVakitler;
          durumMesaji = 'Vakitler hazır. Bilgi için ekrana dokunun veya telefonu sallayın.';
          yuklendi = true;
        });

        await _cevrimdisiVeriKaydet(cekilenVakitler);
        _acilisOzetiniOku();
        _bildirimleriZamanla();
      } else {
        if (vakitler.isEmpty) {
          setState(() => durumMesaji = 'Vakit bilgisi çekilemedi.');
          _seslendir('Vakit verisi alınamadı.');
        }
      }
    } catch (e) {
      if (vakitler.isNotEmpty) {
        _seslendir('İnternet bağlantısı yok, kayıtlı vakitler kullanılıyor.');
      } else {
        setState(() => durumMesaji = 'Bağlantı hatası.');
        _seslendir('İnternet bağlantısı kurulamadı.');
      }
    }
  }

  Future<void> _bildirimleriZamanla() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    final simdi = DateTime.now();
    int bildirimId = 1;

    for (var eleman in vakitler.entries) {
      final parcalar = eleman.value.split(':');
      final vakitAni = DateTime(
        simdi.year,
        simdi.month,
        simdi.day,
        int.parse(parcalar[0]),
        int.parse(parcalar[1]),
      );

      if (vakitAni.isAfter(simdi)) {
        final tz.TZDateTime tzVakit = tz.TZDateTime.from(vakitAni, tz.local);

        await flutterLocalNotificationsPlugin.zonedSchedule(
          id: bildirimId,
          title: 'Ezan Vakti Geldi',
          body: '${eleman.key} vakti girdi.',
          scheduledDate: tzVakit,
          notificationDetails: const NotificationDetails(
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        bildirimId++;
      }
    }
  }

  Map<String, dynamic>? _siradakiVakitBilgisi() {
    if (!yuklendi) return null;
    final simdi = DateTime.now();

    for (var eleman in vakitler.entries) {
      final parcalar = eleman.value.split(':');
      final vakitAni = DateTime(
        simdi.year,
        simdi.month,
        simdi.day,
        int.parse(parcalar[0]),
        int.parse(parcalar[1]),
      );

      if (vakitAni.isAfter(simdi)) {
        return {
          'isim': eleman.key,
          'kalanDakika': vakitAni.difference(simdi).inMinutes,
        };
      }
    }
    return null;
  }

  void _acilisOzetiniOku() {
    final veri = _siradakiVakitBilgisi();
    String metin;
    if (veri != null) {
      final int dakika = veri['kalanDakika'];
      final saat = dakika ~/ 60;
      final kalanDk = dakika % 60;
      final sure = saat > 0 ? '$saat saat $kalanDk dakika' : '$kalanDk dakika';
      metin = 'Sıradaki vakit ${veri['isim']}. Kalan süre $sure.';
    } else {
      metin = 'Bugünkü tüm vakitler tamamlandı. Sıradaki vakit yarın sabah İmsak.';
    }

    Clipboard.setData(ClipboardData(text: metin));
    _seslendir('Vakitler güncellendi. $metin');
  }

  void _siradakiVaktiOku() {
    HapticFeedback.heavyImpact();
    final veri = _siradakiVakitBilgisi();
    String metin;
    if (veri != null) {
      final int dakika = veri['kalanDakika'];
      final saat = dakika ~/ 60;
      final kalanDk = dakika % 60;
      final sure = saat > 0 ? '$saat saat $kalanDk dakika' : '$kalanDk dakika';
      metin = 'Sıradaki vakit: ${veri['isim']}. Kalan süre: $sure.';
    } else {
      metin = 'Günün tüm vakitleri sona erdi.';
    }

    Clipboard.setData(ClipboardData(text: metin));
    _seslendir(metin);
  }

  // --- Sesli Kıble Pusulası ---
  void _kiblePusulasiniBaslat() async {
    setState(() => _kibleModuAcik = true);
    HapticFeedback.heavyImpact();
    _seslendir('Kıble pusulası açıldı. Telefonu düz tutarak yavaşça kendi etrafınızda dönün.');

    await _compassAbonelik?.cancel();

    _compassAbonelik = FlutterCompass.events?.listen((CompassEvent event) {
      if (!_kibleModuAcik) return;

      final double? heading = event.headingForCameraMode ?? event.heading;
      if (heading == null) return;

      double cihazAci = heading;
      if (cihazAci < 0) cihazAci += 360;

      setState(() {
        _mevcutAci = cihazAci;
      });

      double fark = (cihazAci - _kibleAcisi).abs();
      if (fark > 180) fark = 360 - fark;

      final simdi = DateTime.now();

      // Tam Kıble (± 6 derece tolerans)
      if (fark <= 6) {
        if (simdi.difference(_sonKibleUyarisi).inMilliseconds > 2000) {
          _sonKibleUyarisi = simdi;
          HapticFeedback.heavyImpact();
          _seslendir('Tam kıbledesiniz.');
        }
      } else if (fark <= 20) {
        if (simdi.difference(_sonKibleUyarisi).inMilliseconds > 700) {
          _sonKibleUyarisi = simdi;
          HapticFeedback.mediumImpact();
        }
      }
    });
  }

  void _kiblePusulasiniDurdur() {
    _compassAbonelik?.cancel();
    setState(() => _kibleModuAcik = false);
    HapticFeedback.heavyImpact();
    _seslendir('Kıble pusulasından çıkıldı.');
  }

  @override
  Widget build(BuildContext context) {
    if (_kibleModuAcik) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sesli Kıble Pusulası'),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade900,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amberAccent, width: 3),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.explore, size: 90, color: Colors.amberAccent),
                        const SizedBox(height: 16),
                        Text(
                          'Kıble Yönü: ${_kibleAcisi.toStringAsFixed(0)}°\nŞu Anki Yönünüz: ${_mevcutAci.toStringAsFixed(0)}°',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Telefonu yere paralel (düz) tutun ve yavaşça dönün.\n\nTam kıbleye geldiğinizde sesli ve güçlü titreşimle bildirilecektir.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(75),
                    backgroundColor: Colors.red.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.redAccent, width: 2),
                    ),
                  ),
                  onPressed: _kiblePusulasiniDurdur,
                  icon: const Icon(Icons.close, size: 36, color: Colors.white),
                  label: const Text(
                    'Pusulayı Kapat',
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesli Ezan Vakti'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Semantics(
                  label: 'Sıradaki vakti ve kalan süreyi seslendirmek için dokunun veya cihazı sallayın',
                  button: true,
                  child: InkWell(
                    onTap: _siradakiVaktiOku,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade900,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.tealAccent, width: 3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.volume_up, size: 70, color: Colors.tealAccent),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              durumMesaji,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '(Dokunun ya da telefonu sallayın)',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                flex: 1,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(60),
                    backgroundColor: Colors.blueGrey.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.lightBlueAccent, width: 2),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    if (vakitler.isEmpty) return;
                    String ozet = 'Bugünkü vakitler: ' +
                        vakitler.entries
                            .map((e) => '${e.key}: ${e.value}')
                            .join(', ');
                    _seslendir(ozet);
                  },
                  icon: const Icon(Icons.list_alt, size: 36, color: Colors.lightBlueAccent),
                  label: const Text(
                    'Tüm Vakitleri Dinle',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                flex: 1,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(60),
                    backgroundColor: Colors.amber.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.amberAccent, width: 2),
                    ),
                  ),
                  onPressed: _kiblePusulasiniBaslat,
                  icon: const Icon(Icons.explore, size: 36, color: Colors.amberAccent),
                  label: const Text(
                    'Sesli Kıble Pusulası',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}