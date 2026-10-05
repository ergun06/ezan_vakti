import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/prayer_day.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_service.dart';
import '../services/settings_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/accessible_voice_action_bar.dart';
import '../widgets/city_selector_sheet.dart';
import '../widgets/countdown_hero_card.dart';
import '../widgets/daily_inspiration_card.dart';
import '../widgets/prayer_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  PrayerType? _lastTriggeredPrayer;

  @override
  void initState() {
    super.initState();
    // 1-second precision ticker
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
        _checkPrayerAlarm();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkPrayerAlarm() {
    final settings = SettingsService.instance;
    final city = settings.selectedCity;
    final prayerDay = PrayerService.calculatePrayerDay(city, _currentTime);
    final tomorrowFajr = PrayerService.getTomorrowFajr(city, _currentTime);

    final nextPrayer = prayerDay.getNextPrayer(_currentTime);
    final remaining = prayerDay.getTimeRemaining(_currentTime, tomorrowFajr);

    // If remaining is 0 or within 1 second and we haven't triggered this prayer yet today
    if (remaining.inSeconds <= 1 && _lastTriggeredPrayer != nextPrayer) {
      _lastTriggeredPrayer = nextPrayer;

      if (settings.isNotificationEnabled(nextPrayer)) {
        // 1. Show notification
        NotificationService.instance.showNotification(
          title: '${city.name} - ${nextPrayer.turkishName} Vakti Girdi',
          body: '${nextPrayer.turkishName} namazı vakti başladı. Allah kabul etsin.',
        );

        // 2. Tactile vibration feedback
        if (settings.vibrateOnPrayer) {
          HapticFeedback.heavyImpact();
          Future.delayed(const Duration(milliseconds: 350), () => HapticFeedback.heavyImpact());
          Future.delayed(const Duration(milliseconds: 700), () => HapticFeedback.heavyImpact());
        }

        // 3. Turkish Voice announcement for visually impaired
        if (settings.speakAloudOnPrayer) {
          TtsService.instance.speak(
            '${city.name} için ${nextPrayer.turkishName} ezanı vakti girdi. Namaz vakti başladı.',
          );
        }

        // 4. Play audio if enabled
        if (settings.autoPlaySound && settings.soundType != 'silent') {
          final isFajr = nextPrayer == PrayerType.fajr;
          final soundToPlay = isFajr ? 'sabah' : settings.soundType;
          final delay = settings.speakAloudOnPrayer ? 4 : 0;
          Future.delayed(Duration(seconds: delay), () {
            AudioService.instance.playSoundType(
              soundToPlay,
              customTitle: '${city.name} - ${nextPrayer.turkishName} Ezanı',
            );
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.instance;

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        final city = settings.selectedCity;
        final prayerDay = PrayerService.calculatePrayerDay(city, _currentTime);
        final tomorrowFajr = PrayerService.getTomorrowFajr(city, _currentTime);
        final activePrayer = prayerDay.getCurrentPrayer(_currentTime);
        final nextPrayer = prayerDay.getNextPrayer(_currentTime);

        final gregorianStr = DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(_currentTime);

        return Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 40 : 18,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: City Selector & Date
                      _buildHeader(city, gregorianStr, prayerDay.hijriDate),
                      const SizedBox(height: 14),

                      // Large Accessibility Voice & GPS bar
                      AccessibleVoiceActionBar(
                        prayerDay: prayerDay,
                        currentTime: _currentTime,
                        tomorrowFajr: tomorrowFajr,
                        city: city,
                      ),
                      const SizedBox(height: 6),

                      if (isWide)
                        // Two-Column Layout for Desktop / Tablet
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column: Countdown Hero + Inspiration
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  CountdownHeroCard(
                                    prayerDay: prayerDay,
                                    currentTime: _currentTime,
                                    tomorrowFajr: tomorrowFajr,
                                  ),
                                  const SizedBox(height: 18),
                                  DailyInspirationCard(date: _currentTime),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Right Column: Prayer Times Cards
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildPrayerCardsList(
                                    prayerDay,
                                    activePrayer,
                                    nextPrayer,
                                    settings,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        // Single-Column Layout for Mobile
                        Column(
                          children: [
                            CountdownHeroCard(
                              prayerDay: prayerDay,
                              currentTime: _currentTime,
                              tomorrowFajr: tomorrowFajr,
                            ),
                            const SizedBox(height: 18),
                            _buildPrayerCardsList(
                              prayerDay,
                              activePrayer,
                              nextPrayer,
                              settings,
                            ),
                            const SizedBox(height: 18),
                            DailyInspirationCard(date: _currentTime),
                            const SizedBox(height: 24),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(dynamic city, String gregorian, String hijri) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // City Selector Pill
        InkWell(
          onTap: () => CitySelectorSheet.show(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${city.name}, ${city.country}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),

        // Date Display
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              gregorian,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              hijri,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.goldLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrayerCardsList(
    PrayerDay prayerDay,
    PrayerType activePrayer,
    PrayerType nextPrayer,
    SettingsService settings,
  ) {
    const prayers = [
      PrayerType.fajr,
      PrayerType.sunrise,
      PrayerType.dhuhr,
      PrayerType.asr,
      PrayerType.maghrib,
      PrayerType.isha,
    ];

    return Column(
      children: prayers.map((type) {
        final timeStr = prayerDay.getFormattedTime(type);
        final isActive = activePrayer == type;
        final isNext = nextPrayer == type;
        final isEnabled = settings.isNotificationEnabled(type);

        return PrayerCard(
          prayerType: type,
          formattedTime: timeStr,
          isActive: isActive,
          isNext: isNext,
          isNotificationEnabled: isEnabled,
          onToggleNotification: (val) {
            settings.toggleNotification(type, val);
          },
        );
      }).toList(),
    );
  }
}
