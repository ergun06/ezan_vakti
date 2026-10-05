import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/prayer_service.dart';
import '../theme/app_theme.dart';

class DailyInspirationCard extends StatefulWidget {
  final DateTime date;
  const DailyInspirationCard({super.key, required this.date});

  @override
  State<DailyInspirationCard> createState() => _DailyInspirationCardState();
}

class _DailyInspirationCardState extends State<DailyInspirationCard> {
  int _selectedIndex = 0; // 0 = Ayet, 1 = Hadis, 2 = Ezan Duası

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label panoya kopyalandı'),
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = PrayerService.getDailyContent(widget.date);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented switch: Günün Ayeti / Günün Hadisi / Ezan Duası
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _TabButton(
                  title: 'Günün Ayeti',
                  icon: Icons.menu_book_rounded,
                  isSelected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                _TabButton(
                  title: 'Günün Hadisi',
                  icon: Icons.chat_bubble_outline_rounded,
                  isSelected: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                _TabButton(
                  title: 'Ezan Duası',
                  icon: Icons.favorite_border_rounded,
                  isSelected: _selectedIndex == 2,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content body
          if (_selectedIndex == 0) ...[
            Text(
              content.ayahArabic,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'serif',
                height: 1.8,
                color: AppColors.goldLight,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '“${content.ayahTurkish}”',
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  content.ayahSource,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.textMuted),
                  onPressed: () => _copyToClipboard(
                    '${content.ayahArabic}\n\n${content.ayahTurkish}\n(${content.ayahSource})',
                    'Ayet',
                  ),
                  tooltip: 'Kopyala',
                ),
              ],
            ),
          ] else if (_selectedIndex == 1) ...[
            Text(
              content.hadithArabic,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'serif',
                height: 1.8,
                color: AppColors.goldLight,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '“${content.hadithTurkish}”',
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  content.hadithSource,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.textMuted),
                  onPressed: () => _copyToClipboard(
                    '${content.hadithArabic}\n\n${content.hadithTurkish}\n(${content.hadithSource})',
                    'Hadis',
                  ),
                  tooltip: 'Kopyala',
                ),
              ],
            ),
          ] else ...[
            const Text(
              PrayerService.ezanDuasiArabic,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'serif',
                height: 1.8,
                color: AppColors.goldLight,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '“${PrayerService.ezanDuasiTurkish}”',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Buhârî, Ezân 8',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.textMuted),
                  onPressed: () => _copyToClipboard(
                    '${PrayerService.ezanDuasiArabic}\n\n${PrayerService.ezanDuasiTurkish}\n(Buhârî, Ezân 8)',
                    'Ezan Duası',
                  ),
                  tooltip: 'Kopyala',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
