import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onNotificationTap;

  // true  = profile bisa diklik
  // false = sedang berada di halaman profile
  final bool profileEnabled;

  const AppHeader({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.profileEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ============================================================
          // LOGO
          // ============================================================

          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 9),

          // ============================================================
          // BRAND + PAGE TITLE
          // ============================================================
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // EduAdmin Pro
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Arrava',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 3),

                // Nama halaman
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // NOTIFICATION
          // ============================================================
          if (onNotificationTap != null)
            GestureDetector(
              onTap: onNotificationTap,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_none_outlined,
                      size: 23,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(width: 5),

          // ============================================================
          // PROFILE
          // ============================================================
          GestureDetector(
            onTap: profileEnabled
                ? () {
                    Navigator.pushNamed(context, AppRoutes.adminProfile);
                  }
                : null,
            child: Opacity(
              opacity: profileEnabled ? 1.0 : 0.55,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Circle profile
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 21,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
