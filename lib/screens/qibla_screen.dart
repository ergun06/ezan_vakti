import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/prayer_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/city_selector_sheet.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.instance;

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        final city = settings.selectedCity;
        final qiblaDegree = PrayerService.getQiblaDirection(city);
        final distanceKm = PrayerService.getDistanceToKaaba(city);

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Kıble Yönü',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => CitySelectorSheet.show(context),
                icon: const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                label: Text(
                  city.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Compass Circle Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    decoration: AppTheme.glassCardDecoration(
                      shadows: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 260,
                        height: 260,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer decorative ring
                            Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.cardBorder,
                                  width: 2,
                                ),
                                color: AppColors.surfaceElevated.withValues(alpha: 0.4),
                              ),
                            ),
                            // Cardinal points N, E, S, W
                            const Positioned(
                              top: 10,
                              child: Text(
                                'K',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.kerahatRed,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const Positioned(
                              right: 12,
                              child: Text(
                                'D',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const Positioned(
                              bottom: 10,
                              child: Text(
                                'G',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 12,
                              child: Text(
                                'B',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                  fontSize: 15,
                                ),
                              ),
                            ),

                            // Rotating needle pointing to Qibla angle
                            Transform.rotate(
                              angle: (qiblaDegree * math.pi / 180),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Pointer line
                                  Container(
                                    width: 4,
                                    height: 190,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppColors.gold,
                                          Colors.transparent,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  // Kaaba icon at the tip
                                  Positioned(
                                    top: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: AppColors.gold,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.gold,
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.mosque,
                                        size: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Center Pivot Dot
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats Row: Degree & Distance
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Kıble Açısı (Kuzeyden)',
                          value: '${qiblaDegree.toStringAsFixed(1)}°',
                          subtitle: 'Pusula İstikameti',
                          icon: Icons.explore_rounded,
                          accentColor: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _StatCard(
                          title: 'Kâbe Mesafesi',
                          value: '${distanceKm.toStringAsFixed(0)} km',
                          subtitle: 'Kuş Uçuşu',
                          icon: Icons.flight_takeoff_rounded,
                          accentColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Info Tip
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.blueAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pusulayı yatay bir zemine koyup cihazınızın yönünü kuzeye çevirdiğinizde, altın sarısı Kâbe ibresi ${city.name} için tam kıble yönünü göstermektedir.',
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: accentColor),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
