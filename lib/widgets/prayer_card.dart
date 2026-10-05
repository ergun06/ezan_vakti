import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/prayer_day.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

class PrayerCard extends StatelessWidget {
  final PrayerType prayerType;
  final String formattedTime;
  final bool isActive;
  final bool isNext;
  final bool isNotificationEnabled;
  final ValueChanged<bool> onToggleNotification;

  const PrayerCard({
    super.key,
    required this.prayerType,
    required this.formattedTime,
    required this.isActive,
    required this.isNext,
    required this.isNotificationEnabled,
    required this.onToggleNotification,
  });

  IconData _getIcon() {
    switch (prayerType) {
      case PrayerType.fajr:
        return Icons.nightlight_round;
      case PrayerType.sunrise:
        return Icons.wb_sunny_outlined;
      case PrayerType.dhuhr:
        return Icons.wb_sunny;
      case PrayerType.asr:
        return Icons.wb_twilight;
      case PrayerType.maghrib:
        return Icons.nights_stay;
      case PrayerType.isha:
        return Icons.bedtime;
      case PrayerType.none:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    if (isActive) {
      iconColor = AppColors.primaryLight;
    } else if (isNext) {
      iconColor = AppColors.gold;
    } else {
      iconColor = AppColors.textSecondary;
    }

    final semanticLabel =
        '${prayerType.turkishName} vakti. Saat $formattedTime. '
        '${isActive ? "Şu an bu vakit içindesiniz. " : ""}'
        '${isNext ? "Sıradaki vakit. " : ""}'
        'Bildirim ${isNotificationEnabled ? "açık" : "kapalı"}.';

    return Semantics(
      button: true,
      label: semanticLabel,
      hint: 'Vakti sesli dinlemek için dokunun. Bildirimi değiştirmek için zil butonuna dokunun.',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: isActive
            ? AppTheme.activePrayerDecoration()
            : BoxDecoration(
                color: isNext
                    ? const Color(0xFF16253C)
                    : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isNext
                      ? AppColors.gold.withValues(alpha: 0.5)
                      : AppColors.cardBorder,
                  width: isNext ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticFeedback.selectionClick();
              TtsService.instance.speak(
                '${prayerType.turkishName} vakti, saat $formattedTime. '
                '${isActive ? "Şu an bu vakit içindesiniz. " : ""}'
                '${isNext ? "Sıradaki vakit. " : ""}'
                'Bildirim ${isNotificationEnabled ? "açık" : "kapalı"}.',
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Prayer Icon with background circle
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withValues(alpha: 0.25)
                          : AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIcon(),
                      size: 22,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Titles: Turkish & Arabic
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            Text(
                              prayerType.turkishName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isActive || isNext ? FontWeight.bold : FontWeight.w600,
                                color: isActive
                                    ? Colors.white
                                    : (isNext
                                        ? AppColors.goldLight
                                        : AppColors.textPrimary),
                              ),
                            ),
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'ŞU AN',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            else if (isNext)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.gold.withValues(alpha: 0.6),
                                    width: 0.8,
                                  ),
                                ),
                                child: const Text(
                                  'SIRADAKİ',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.goldLight,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          prayerType.arabicName,
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive
                                ? AppColors.primaryLight.withValues(alpha: 0.9)
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Prayer Time formatted (e.g. 13:04)
                  Text(
                    formattedTime,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isActive
                          ? AppColors.primaryLight
                          : (isNext ? AppColors.goldLight : AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Bell toggle icon
                  IconButton(
                    onPressed: () {
                      final nextState = !isNotificationEnabled;
                      onToggleNotification(nextState);
                      HapticFeedback.lightImpact();
                      TtsService.instance.speak(
                        '${prayerType.turkishName} vakti bildirimi ${nextState ? "açıldı" : "kapatıldı"}.',
                      );
                    },
                    icon: Icon(
                      isNotificationEnabled
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_off_outlined,
                      size: 20,
                      color: isNotificationEnabled
                          ? (isActive ? AppColors.primaryLight : AppColors.gold)
                          : AppColors.textMuted.withValues(alpha: 0.5),
                    ),
                    tooltip: isNotificationEnabled ? 'Bildirim Açık' : 'Bildirim Kapalı',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
