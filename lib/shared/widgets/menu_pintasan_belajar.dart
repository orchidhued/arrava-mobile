import 'package:flutter/material.dart';

class MenuPintasanBelajar extends StatelessWidget {
  final int modulCount;
  final int quizCount;
  final String currentRank;
  final VoidCallback? onMateriTap;
  final VoidCallback? onKuisTap;
  final VoidCallback? onPresensiTap;
  final VoidCallback? onPeringkatTap;

  const MenuPintasanBelajar({
    super.key,
    this.modulCount = 0,
    this.quizCount = 0,
    this.currentRank = 'Pemula',
    this.onMateriTap,
    this.onKuisTap,
    this.onPresensiTap,
    this.onPeringkatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCEFFF), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFB2E7FC),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar: "MENU PINTASAN BELAJAR" & Pill "Akses Cepat"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MENU PINTASAN BELAJAR',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: Color(0xFF72839E),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF3FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFB2E7FC)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF007FBE),
                      ),
                    ),
                    const SizedBox(width: 4.5),
                    const Text(
                      'Akses Cepat',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF007FBE),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Container(
            height: 1,
            color: const Color(0xFFF0F6FF),
          ),
          const SizedBox(height: 12),

          // 4 Shortcut Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Materi Modul
              _buildShortcutItem(
                title: 'Materi',
                subtitle: '$modulCount Modul',
                gradientColors: const [Color(0xFFEBF7FF), Color(0xFFDDF3FF)],
                borderColor: const Color(0xFFB2E7FC),
                shadowColor: const Color(0xFF007FBE),
                badgeCount: modulCount,
                badgeColor: const Color(0xFF007FBE),
                content: Image.asset(
                  'assets/karakter/membacaDokumen/glasess_girl_readingl1.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
                onTap: onMateriTap,
              ),

              // 2. Quiz Latihan
              _buildShortcutItem(
                title: 'Kuis',
                subtitle: '$quizCount Kuis',
                gradientColors: const [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                borderColor: const Color(0xFFBBF7D0),
                shadowColor: const Color(0xFF059669),
                badgeCount: quizCount,
                badgeColor: const Color(0xFF059669),
                content: Image.asset(
                  'assets/karakter/quiz/quizgirl1.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
                onTap: onKuisTap,
              ),

              // 3. Presensi QR
              _buildShortcutItem(
                title: 'Presensi',
                subtitle: 'QR Code',
                gradientColors: const [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                borderColor: const Color(0xFFFDE68A),
                shadowColor: const Color(0xFFD97706),
                content: const Icon(
                  Icons.qr_code_2_rounded,
                  size: 28,
                  color: Color(0xFFD97706),
                ),
                onTap: onPresensiTap,
              ),

              // 4. Peringkat / Leaderboard
              _buildShortcutItem(
                title: 'Peringkat',
                subtitle: currentRank,
                gradientColors: const [Color(0xFFF3E8FF), Color(0xFFEDE9FE)],
                borderColor: const Color(0xFFDDD6FE),
                shadowColor: const Color(0xFF7C3AED),
                content: const Text(
                  '🏆',
                  style: TextStyle(fontSize: 24),
                ),
                onTap: onPeringkatTap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutItem({
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required Color borderColor,
    required Color shadowColor,
    required Widget content,
    int? badgeCount,
    Color? badgeColor,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Button with 3D bottom shadow
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: gradientColors,
                      ),
                      border: Border.all(color: borderColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          offset: const Offset(0, 3.5),
                        ),
                      ],
                    ),
                    child: Center(child: content),
                  ),

                  // Notification Badge if applicable
                  if (badgeCount != null && badgeCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                        decoration: BoxDecoration(
                          color: badgeColor ?? shadowColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            badgeCount > 99 ? '99+' : '$badgeCount',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Title Label (Bold Dark Navy)
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF082765),
                ),
              ),

              const SizedBox(height: 2),

              // Subtitle Label (Grey/Slate)
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF72839E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

