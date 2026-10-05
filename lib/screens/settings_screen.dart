import 'package:flutter/material.dart';
import '../models/prayer_day.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../services/tts_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/city_selector_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.instance;

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Ayarlar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              children: [
                // 1. Şehir Seçimi Bölümü
                _SectionTitle('KONUM & ŞEHİR'),
                Container(
                  decoration: AppTheme.glassCardDecoration(),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceElevated,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        settings.selectedCity.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '${settings.selectedCity.country} (Enlem: ${settings.selectedCity.latitude.toStringAsFixed(2)}, Boylam: ${settings.selectedCity.longitude.toStringAsFixed(2)})',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                      ),
                      onTap: () => CitySelectorSheet.show(context),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 2. Ses ve Ezan Alarmı Ayarları
                _SectionTitle('EZAN SESİ & ALARM'),
                Container(
                  decoration: AppTheme.glassCardDecoration(),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        // Sound choice dropdown
                        ListTile(
                          leading: const Icon(Icons.music_note_rounded,
                              color: AppColors.gold),
                          title: const Text(
                            'Ezan / Uyarı Sesi',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Vakit girdiğinde çalınacak ses',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          trailing: DropdownButton<String>(
                            value: settings.soundType,
                            dropdownColor: AppColors.surfaceCard,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(
                                value: 'mekke',
                                child: Text('Mekke Ezanı'),
                              ),
                              DropdownMenuItem(
                                value: 'sabah',
                                child: Text('Sabah Ezanı'),
                              ),
                              DropdownMenuItem(
                                value: 'chime',
                                child: Text('Melodik Zil'),
                              ),
                              DropdownMenuItem(
                                value: 'silent',
                                child: Text('Sessiz (Yalnız Bildirim)'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) settings.setSoundType(val);
                            },
                          ),
                        ),
                        const Divider(color: AppColors.cardBorder, height: 1),

                        // Auto play toggle
                        SwitchListTile(
                          secondary: const Icon(Icons.alarm_on_rounded,
                              color: AppColors.primary),
                          title: const Text(
                            'Vakit Girdiğinde Otomatik Çal',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Geri sayım sıfırlandığında ezanı başlatır',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          value: settings.autoPlaySound,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) => settings.setAutoPlaySound(val),
                        ),
                        const Divider(color: AppColors.cardBorder, height: 1),

                        // Test sound button
                        ValueListenableBuilder<bool>(
                          valueListenable: AudioService.instance.isPlayingNotifier,
                          builder: (context, isPlaying, _) {
                            return ListTile(
                              leading: Icon(
                                isPlaying
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.play_circle_filled_rounded,
                                color: isPlaying
                                    ? AppColors.kerahatRed
                                    : AppColors.goldLight,
                              ),
                              title: Text(
                                isPlaying
                                    ? 'Ezan Çalıyor (Durdurmak için dokun)'
                                    : 'Ezan Sesini Test Et',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isPlaying
                                      ? AppColors.kerahatRed
                                      : AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                isPlaying
                                    ? 'Şu an seçili olan ses yürütülüyor'
                                    : 'Seçili sesi dinleyip test edin',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textMuted),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  if (isPlaying) {
                                    AudioService.instance.stop();
                                  } else {
                                    AudioService.instance.playSoundType(
                                      settings.soundType,
                                      customTitle: 'Test: ${settings.soundType.toUpperCase()}',
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isPlaying
                                      ? AppColors.kerahatRed
                                      : AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(isPlaying ? 'Durdur' : 'Çal'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Vakit Bildirimleri
                _SectionTitle('BİLDİRİM TERCİHLERİ'),
                Container(
                  decoration: AppTheme.glassCardDecoration(),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        // Test notification button
                        ListTile(
                          leading: const Icon(Icons.notifications_active_rounded,
                              color: AppColors.primary),
                          title: const Text(
                            'Test Bildirimi Gönder',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            'Cihazın bildirim iznini ve görünümünü test edin',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          trailing: OutlinedButton(
                            onPressed: () async {
                              await NotificationService.instance.requestPermissions();
                              await NotificationService.instance.showNotification(
                                title: 'Ezan Vakti - Bildirim Testi',
                                body:
                                    '${settings.selectedCity.name} için bildirimler başarıyla aktifleştirildi.',
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Test bildirimi gönderildi!'),
                                    backgroundColor: AppColors.primaryDark,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Gönder',
                              style: TextStyle(color: AppColors.primaryLight),
                            ),
                          ),
                        ),
                        const Divider(color: AppColors.cardBorder, height: 1),

                        // Prayer toggles
                        _PrayerToggleTile(
                          prayerType: PrayerType.fajr,
                          value: settings.fajrNotification,
                          onChanged: (v) =>
                              settings.toggleNotification(PrayerType.fajr, v),
                        ),
                        const Divider(color: AppColors.cardBorder, height: 1),
                        _PrayerToggleTile(
                          prayerType: PrayerType.sunrise,
                          value: settings.sunriseNotification,
                          onChanged: (v) =>
                              settings.toggleNotification(PrayerType.sunrise, v),
                        ),
                        const Divider(color: AppColors.cardBorder, height: 1),
                        _PrayerToggleTile(
                          prayerType: PrayerType.dhuhr,
                          value: settings.dhuhrNotification,
                          onChanged: (v) =>
                              settings.toggleNotification(PrayerType.dhuhr, v),
                        ),
                        const Divider(color: AppColors.cardBorder, height: 1),
                        _PrayerToggleTile(
                          prayerType: PrayerType.asr,
                          value: settings.asrNotification,
                          onChanged: (v) =>
                              settings.toggleNotification(PrayerType.asr, v),
                        ),
                        const Divider(color: AppColors.cardBorder, height: 1),
                        _PrayerToggleTile(
                          prayerType: PrayerType.maghrib,
                          value: settings.maghribNotification,
                          onChanged: (v) =>
                              settings.toggleNotification(PrayerType.maghrib, v),
                        ),
                        const Divider(color: AppColors.cardBorder, height: 1),
                        _PrayerToggleTile(
                          prayerType: PrayerType.isha,
                          value: settings.ishaNotification,
                          onChanged: (v) =>
                              settings.toggleNotification(PrayerType.isha, v),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 4. Görme Engelli Erişilebilirlik Bölümü
                _SectionTitle('GÖRME ENGELLİ ERİŞİLEBİLİRLİK'),
                Container(
                  decoration: AppTheme.glassCardDecoration(),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        // Speak aloud on prayer switch
                        SwitchListTile(
                          secondary: const Icon(Icons.record_voice_over_rounded,
                              color: AppColors.primary),
                          title: const Text(
                            'Vakit Girdiğinde Sesli Konuş (TTS)',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Ezan vaktinde vakti ve detayları Türkçe sesli söyler',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          value: settings.speakAloudOnPrayer,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) {
                            settings.setSpeakAloudOnPrayer(val);
                            if (val) {
                              TtsService.instance.speak('Sesli okuma bildirimi açıldı.');
                            }
                          },
                        ),
                        const Divider(color: AppColors.cardBorder, height: 1),

                        // Vibration switch
                        SwitchListTile(
                          secondary: const Icon(Icons.vibration_rounded,
                              color: AppColors.gold),
                          title: const Text(
                            'Titreşimli Vakit Uyarısı',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Vakit girdiğinde güçlü titreşim darbeleri verir',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          value: settings.vibrateOnPrayer,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) => settings.setVibrateOnPrayer(val),
                        ),
                        const Divider(color: AppColors.cardBorder, height: 1),

                        // GPS Auto Location Detection
                        ListTile(
                          leading: const Icon(Icons.my_location_rounded,
                              color: AppColors.blueAccent),
                          title: const Text(
                            'GPS ile Konumumu Tespit Et',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Bulunduğunuz enlem ve boylama göre vakitleri günceller',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              TtsService.instance.speak('Konumunuz alınıyor, lütfen bekleyin.');
                              final city = await LocationService.instance.determinePosition();
                              if (city != null) {
                                await settings.setCity(city);
                                TtsService.instance.speak(
                                  'Konumunuz güncellendi. ${city.name} için vakitler ayarlandı.',
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Konum güncellendi: ${city.name}'),
                                      backgroundColor: AppColors.primaryDark,
                                    ),
                                  );
                                }
                              } else {
                                TtsService.instance.speak('Konum alınamadı. İzinleri kontrol edin.');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Konumu Al'),
                          ),
                        ),
                        const Divider(color: AppColors.cardBorder, height: 1),

                        // Test Voice Announcement
                        ListTile(
                          leading: const Icon(Icons.campaign_rounded,
                              color: AppColors.goldLight),
                          title: const Text(
                            'Sesli Asistanı Test Et',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Türkçe sesli asistan anonsunu dinleyin',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          trailing: OutlinedButton(
                            onPressed: () {
                              TtsService.instance.speak(
                                'Ezan Vakti görme engelliler sesli asistan sistemi devrede. '
                                'Bulunduğunuz şehir: ${settings.selectedCity.name}. '
                                'Vakit girdiğinde bu ses ile haberdar edileceksiniz.',
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.gold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Dinle',
                              style: TextStyle(color: AppColors.goldLight),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 4. Bilgi ve Hesaplama Yöntemi
                _SectionTitle('HESAPLAMA METODU & HAKKINDA'),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.glassCardDecoration(),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified_rounded,
                              color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Diyanet İşleri Başkanlığı Kriterleri',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Vakitler, Diyanet İşleri Başkanlığı’nın kullandığı astronomik parametreler (Fecr: 18°, Yatsı: 17°, Hanefi asr standardı) ve tam koordinat tabanlı hesaplama algoritması ile cihazınızda yerel ve çevrimdışı olarak hesaplanmaktadır. İnternet bağlantısına ihtiyaç duymaz.',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _PrayerToggleTile extends StatelessWidget {
  final PrayerType prayerType;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrayerToggleTile({
    required this.prayerType,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        '${prayerType.turkishName} Bildirimi',
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14.5),
      ),
      subtitle: Text(
        prayerType.arabicName,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
      value: value,
      activeThumbColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}
