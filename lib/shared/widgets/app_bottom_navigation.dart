import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A007FBE),
            blurRadius: 20,
            offset: Offset(0, -3),
          ),
        ],
        border: Border(
          top: BorderSide(color: Color(0xFFE2F0FD), width: 1.2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavigationItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Beranda',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),

              _NavigationItem(
                icon: Icons.menu_book_outlined,
                activeIcon: Icons.menu_book_rounded,
                label: 'Modul',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),

              _NavigationItem(
                icon: Icons.school_outlined,
                activeIcon: Icons.school_rounded,
                label: 'Guru',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),

              _NavigationItem(
                icon: Icons.people_outline,
                activeIcon: Icons.people_rounded,
                label: 'Siswa',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),

              _NavigationItem(
                icon: Icons.qr_code_scanner_outlined,
                activeIcon: Icons.qr_code_scanner_rounded,
                label: 'Presensi',
                isSelected: currentIndex == 4,
                onTap: () => onTap(4),
              ),

              _NavigationItem(
                icon: Icons.quiz_outlined,
                activeIcon: Icons.quiz_rounded,
                label: 'Kuis',
                isSelected: currentIndex == 5,
                onTap: () => onTap(5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.primary;
    const inactiveColor = Color(0xFF72839E);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFDDF3FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 21,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              label,
              style: GoogleFonts.nunitoSans(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected ? activeColor : inactiveColor,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
