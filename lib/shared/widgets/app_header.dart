import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/notification_provider.dart';
import 'arrava_logo.dart';
import 'notification_sheet.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onLogoutTap;

  // true  = profile bisa diklik
  // false = sedang berada di halaman profile
  final bool profileEnabled;

  const AppHeader({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.onLogoutTap,
    this.profileEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1.5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C007FBE),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ============================================================
          // LOGO
          // ============================================================
          const ArravaLogo(size: 34),

          const SizedBox(width: 10),

          // ============================================================
          // BRAND + PAGE TITLE
          // ============================================================
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Arrava',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    height: 1.1,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // NOTIFICATION
          // ============================================================
          GestureDetector(
            onTap: onNotificationTap ?? () => NotificationSheet.show(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFB2E7FC),
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Consumer<NotificationProvider>(
                builder: (context, notifProv, _) {
                  final unread = notifProv.unreadCount;
                  return Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        size: 21,
                        color: AppColors.textPrimary,
                      ),
                      if (unread > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ============================================================
          // PROFILE
          // ============================================================
          GestureDetector(
            onTap: profileEnabled
                ? () {
                    Navigator.pushNamed(context, '/admin/profile');
                  }
                : null,
            child: Opacity(
              opacity: profileEnabled ? 1.0 : 0.55,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF3FF),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF67D7FC),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFB2E7FC),
                      offset: Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          // ============================================================
          // LOGOUT
          // ============================================================
          if (onLogoutTap != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onLogoutTap,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECEE),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFCDD2),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFFFCDD2),
                      offset: Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 19,
                  color: Color(0xFFDC2626),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
