import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prayer_day.dart';
import '../services/prayer_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/city_selector_sheet.dart';

class ImsakiyeScreen extends StatefulWidget {
  const ImsakiyeScreen({super.key});

  @override
  State<ImsakiyeScreen> createState() => _ImsakiyeScreenState();
}

class _ImsakiyeScreenState extends State<ImsakiyeScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.instance;
    final city = settings.selectedCity;
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy', 'tr_TR').format(_selectedMonth);
    final days = PrayerService.getMonthlyImsakiye(
      city,
      _selectedMonth.year,
      _selectedMonth.month,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aylık İmsakiye',
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
        child: Column(
          children: [
            // Month navigation bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary),
                    onPressed: _previousMonth,
                  ),
                  Text(
                    monthName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
            ),

            // Table Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 52,
                    child: Text(
                      'Tarih',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  Expanded(child: _ColHeader('İmsak')),
                  Expanded(child: _ColHeader('Güneş')),
                  Expanded(child: _ColHeader('Öğle')),
                  Expanded(child: _ColHeader('İkindi')),
                  Expanded(child: _ColHeader('Akşam')),
                  Expanded(child: _ColHeader('Yatsı')),
                ],
              ),
            ),

            // Table Rows
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final isToday = day.date.year == now.year &&
                      day.date.month == now.month &&
                      day.date.day == now.day;

                  final dayStr = DateFormat('dd E', 'tr_TR').format(day.date);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.primary.withValues(alpha: 0.18)
                          : (index.isEven
                              ? AppColors.surfaceCard
                              : AppColors.surfaceCard.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isToday ? AppColors.primary : Colors.transparent,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 52,
                          child: Text(
                            dayStr,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                              color: isToday ? AppColors.primaryLight : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(child: _TimeCell(day.getFormattedTime(PrayerType.fajr), isToday)),
                        Expanded(child: _TimeCell(day.getFormattedTime(PrayerType.sunrise), isToday)),
                        Expanded(child: _TimeCell(day.getFormattedTime(PrayerType.dhuhr), isToday)),
                        Expanded(child: _TimeCell(day.getFormattedTime(PrayerType.asr), isToday)),
                        Expanded(child: _TimeCell(day.getFormattedTime(PrayerType.maghrib), isToday)),
                        Expanded(child: _TimeCell(day.getFormattedTime(PrayerType.isha), isToday)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String title;
  const _ColHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _TimeCell extends StatelessWidget {
  final String time;
  final bool isToday;
  const _TimeCell(this.time, this.isToday);

  @override
  Widget build(BuildContext context) {
    return Text(
      time,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
        color: isToday ? Colors.white : AppColors.textSecondary,
      ),
    );
  }
}
