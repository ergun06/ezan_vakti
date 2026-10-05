import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/city.dart';
import '../models/prayer_day.dart';
import '../services/location_service.dart';
import '../services/settings_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

class AccessibleVoiceActionBar extends StatefulWidget {
  final PrayerDay prayerDay;
  final DateTime currentTime;
  final DateTime tomorrowFajr;
  final City city;

  const AccessibleVoiceActionBar({
    super.key,
    required this.prayerDay,
    required this.currentTime,
    required this.tomorrowFajr,
    required this.city,
  });

  @override
  State<AccessibleVoiceActionBar> createState() => _AccessibleVoiceActionBarState();
}

class _AccessibleVoiceActionBarState extends State<AccessibleVoiceActionBar> {
  bool _isLoadingLocation = false;

  void _speakAllTimes() {
    HapticFeedback.heavyImpact();
    final next = widget.prayerDay.getNextPrayer(widget.currentTime);
    final remaining = widget.prayerDay.getTimeRemaining(widget.currentTime, widget.tomorrowFajr);
    final nextTime = widget.prayerDay.getNextPrayerTime(widget.currentTime, widget.tomorrowFajr);

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final timeStr = hours > 0
        ? '$hours saat $minutes dakika'
        : '$minutes dakika';

    final nextTimeFormatted =
        "${nextTime.hour.toString().padLeft(2, '0')}:${nextTime.minute.toString().padLeft(2, '0')}";

    final imsak = widget.prayerDay.getFormattedTime(PrayerType.fajr);
    final gunes = widget.prayerDay.getFormattedTime(PrayerType.sunrise);
    final ogle = widget.prayerDay.getFormattedTime(PrayerType.dhuhr);
    final ikindi = widget.prayerDay.getFormattedTime(PrayerType.asr);
    final aksam = widget.prayerDay.getFormattedTime(PrayerType.maghrib);
    final yatsi = widget.prayerDay.getFormattedTime(PrayerType.isha);

    final speech =
        'Bulunduğunuz konum: ${widget.city.name}. '
        'Sıradaki vakit: ${next.turkishName}. '
        '${next.turkishName} vaktinin girmesine $timeStr var. Saat: $nextTimeFormatted. '
        'Günün tüm vakitleri: '
        'İmsak $imsak, '
        'Güneş $gunes, '
        'Öğle $ogle, '
        'İkindi $ikindi, '
        'Akşam $aksam, '
        'Yatsı $yatsi.';

    TtsService.instance.speak(speech);
  }

  Future<void> _updateLocation() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoadingLocation = true);
    TtsService.instance.speak('Konumunuz GPS üzerinden alınıyor, lütfen bekleyin.');

    final newCity = await LocationService.instance.determinePosition();
    setState(() => _isLoadingLocation = false);

    if (newCity != null) {
      await SettingsService.instance.setCity(newCity);
      HapticFeedback.heavyImpact();
      TtsService.instance.speak(
        'Konumunuz başarıyla alındı. ${newCity.name} için ezan vakitleri hesaplandı.',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Konum güncellendi: ${newCity.name}'),
            backgroundColor: AppColors.primaryDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      HapticFeedback.vibrate();
      TtsService.instance.speak(
        'Konum bilgisi alınamadı. Lütfen cihazınızın konum servisinin açık olduğundan ve izin verildiğinden emin olun.',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konum alınamadı. İzinleri kontrol edin.'),
            backgroundColor: AppColors.kerahatRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: TtsService.instance.isSpeakingNotifier,
      builder: (context, isSpeaking, _) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              // Main Large Read Aloud Accessibility Button
              Semantics(
                button: true,
                label: isSpeaking
                    ? 'Sesli okumayı durdurmak için dokunun'
                    : 'Vakitleri sesli dinlemek için dokunun',
                hint: 'Konumunuzu, sıradaki vakti ve tüm ezan vakitlerini Türkçe seslendirir',
                child: Material(
                  color: isSpeaking ? AppColors.kerahatRed : AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  elevation: 6,
                  shadowColor: isSpeaking
                      ? AppColors.kerahatRed.withValues(alpha: 0.4)
                      : AppColors.primary.withValues(alpha: 0.4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: isSpeaking
                        ? () => TtsService.instance.stop()
                        : _speakAllTimes,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSpeaking ? Icons.stop_rounded : Icons.record_voice_over_rounded,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isSpeaking ? 'SESLENDİRMEYİ DURDUR' : 'VAKİTLERİ SESLİ DİNLE',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isSpeaking
                                      ? 'Konuşmayı kesmek için dokunun'
                                      : 'Görme engelli sesli asistan (Dokun ve Dinle)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isSpeaking ? Icons.pause_circle_filled : Icons.volume_up_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // GPS Location Trigger Button (High Accessibility)
              Semantics(
                button: true,
                label: 'Konumumu GPS ile otomatik algıla ve vakitleri güncelle',
                hint: 'Cihazınızın GPS koordinatlarına göre en doğru ezan vakitlerini hesaplar',
                child: Material(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _isLoadingLocation ? null : _updateLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isLoadingLocation ? Icons.hourglass_top_rounded : Icons.my_location_rounded,
                            color: AppColors.goldLight,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isLoadingLocation
                                  ? 'Konum Alınıyor...'
                                  : 'Konumuma Göre Vakitleri Hesapla (GPS)',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.goldLight,
                              ),
                            ),
                          ),
                          if (_isLoadingLocation)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.gold,
                              ),
                            )
                          else
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.gold,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
