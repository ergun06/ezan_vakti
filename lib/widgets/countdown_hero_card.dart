import 'package:flutter/material.dart';
import '../models/prayer_day.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';

class CountdownHeroCard extends StatelessWidget {
  final PrayerDay prayerDay;
  final DateTime currentTime;
  final DateTime tomorrowFajr;

  const CountdownHeroCard({
    super.key,
    required this.prayerDay,
    required this.currentTime,
    required this.tomorrowFajr,
  });

  @override
  Widget build(BuildContext context) {
    final nextPrayer = prayerDay.getNextPrayer(currentTime);
    final currentPrayer = prayerDay.getCurrentPrayer(currentTime);
    final remaining = prayerDay.getTimeRemaining(currentTime, tomorrowFajr);
    final progress = prayerDay.getProgress(currentTime, tomorrowFajr);
    final kerahat = prayerDay.getKerahatWarning(currentTime);
    final nextTime = prayerDay.getNextPrayerTime(currentTime, tomorrowFajr);

    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');

    final nextFormattedTime =
        "${nextTime.hour.toString().padLeft(2, '0')}:${nextTime.minute.toString().padLeft(2, '0')}";

    return Column(
      children: [
        // Main Glow Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF132238),
                Color(0xFF0D1829),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 28,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top status row: Current prayer pill + Next prayer time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Şu An: ${currentPrayer.turkishName}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_filled,
                            size: 14, color: AppColors.gold),
                        const SizedBox(width: 5),
                        Text(
                          'Vakit: $nextFormattedTime',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title for next prayer
              Text(
                '${nextPrayer.turkishName.toUpperCase()} VAKTİNE KALAN',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Large Countdown Numbers
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  _TimeBox(label: 'SAAT', value: hours),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w300,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                  _TimeBox(label: 'DAKİKA', value: minutes),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w300,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                  _TimeBox(label: 'SANİYE', value: seconds, isSeconds: true),
                ],
              ),
              const SizedBox(height: 22),

              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 8,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.surfaceCard,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentPrayer.turkishName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        '%${(progress * 100).toInt()} Tamamlandı',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        nextPrayer.turkishName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Audio Controls Quick Bar (Listen / Stop)
              ValueListenableBuilder<bool>(
                valueListenable: AudioService.instance.isPlayingNotifier,
                builder: (context, isPlaying, _) {
                  if (isPlaying) {
                    return ValueListenableBuilder<String?>(
                      valueListenable: AudioService.instance.currentPlayingTitleNotifier,
                      builder: (context, title, _) {
                        return Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.volume_up,
                                  color: AppColors.primaryLight, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  title ?? 'Ezan Çalıyor...',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => AudioService.instance.stop(),
                                icon: const Icon(Icons.stop, size: 16),
                                label: const Text('Durdur'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.kerahatRed,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  textStyle: const TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          final settings = SettingsService.instance;
                          AudioService.instance.playSoundType(
                            settings.soundType,
                            customTitle: '${settings.selectedCity.name} Ezanı',
                          );
                        },
                        icon: const Icon(Icons.play_circle_outline,
                            size: 18, color: AppColors.gold),
                        label: const Text(
                          'Ezanı Dinle',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.goldLight,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        // Kerahat Alert Banner if active
        if (kerahat != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.kerahatBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.kerahatRed.withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.kerahatRed,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    kerahat,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFFFCA5A5),
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isSeconds;

  const _TimeBox({
    required this.label,
    required this.value,
    this.isSeconds = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSeconds
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSeconds
                  ? AppColors.primaryLight.withValues(alpha: 0.4)
                  : AppColors.cardBorder,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: isSeconds ? AppColors.primaryLight : AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
