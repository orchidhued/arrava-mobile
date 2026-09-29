import 'package:flutter/material.dart';

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
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavigationItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Beranda',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),

              _NavigationItem(
                icon: Icons.menu_book_outlined,
                activeIcon: Icons.menu_book,
                label: 'Modul',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),

              _NavigationItem(
                icon: Icons.school_outlined,
                activeIcon: Icons.school,
                label: 'Guru',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),

              _NavigationItem(
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                label: 'Siswa',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),

              _NavigationItem(
                icon: Icons.quiz_outlined,
                activeIcon: Icons.quiz,
                label: 'Kuis',
                isSelected: currentIndex == 4,
                onTap: () => onTap(4),
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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),

            const SizedBox(height: 3),

            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 3),
          ],
        ),
      ),
    );
  }
}
