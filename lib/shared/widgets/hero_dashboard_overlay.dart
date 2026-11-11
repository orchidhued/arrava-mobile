import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/api_constants.dart';
import '../../providers/notification_provider.dart';

/// Konten overlay bersama (Profil Siswa, Kartu Peringkat & EXP, tombol Ganti Hero,
/// serta Sapaan & Pintasan Cepat) untuk tema hero Samudra maupun Galaksi.
class HeroDashboardOverlay extends StatelessWidget {
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? stats;
  final int modulCount;
  final int quizCount;
  final String heroTheme;
  final VoidCallback? onExploreTap;
  final VoidCallback? onQuizTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLeaderboardTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onToggleHeroTheme;
  final bool isHeroSwitching;

  const HeroDashboardOverlay({
    super.key,
    this.user,
    this.stats,
    this.modulCount = 0,
    this.quizCount = 0,
    this.heroTheme = 'samudra',
    this.onExploreTap,
    this.onQuizTap,
    this.onProfileTap,
    this.onLeaderboardTap,
    this.onNotificationTap,
    this.onToggleHeroTheme,
    this.isHeroSwitching = false,
  });

  bool get _isGalaksi => heroTheme == 'galaksi';

  String _formatNumber(int n) {
    final s = n.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    final rankInfo = (user?['rank_tier'] as Map<String, dynamic>?) ??
        (user?['rank'] as Map<String, dynamic>?) ??
        <String, dynamic>{};

    final currentRank = rankInfo['current_rank']?.toString() ?? 'Pemula';
    final currentBadgeUrl = rankInfo['current_badge_url']?.toString();
    final nextRank = rankInfo['next_rank']?.toString() ?? 'Lanjutan';
    final currentPoints = (rankInfo['current_points'] as num?)?.toInt() ??
        (user?['total_xp'] as num?)?.toInt() ??
        (stats?['total_xp'] as num?)?.toInt() ??
        0;
    final nextPoints = (rankInfo['next_points'] as num?)?.toInt() ?? 100;
    final pointsNeeded = (rankInfo['points_needed'] as num?)?.toInt() ??
        (nextPoints > currentPoints ? nextPoints - currentPoints : 0);
    final percent = ((rankInfo['percent'] as num?)?.toInt() ??
            (stats?['progress_percent'] as num?)?.toInt() ??
            0)
        .clamp(0, 100);
    final isMax = rankInfo['is_max'] == true;

    final kuisLulus = stats?['kuis_lulus'] ?? 0;
    final effectiveModulCount =
        modulCount > 0 ? modulCount : (stats?['kursus_aktif'] ?? 0);
    final jenjangName = user?['jenjang']?.toString() ?? 'SD';
    final studentName = user?['nama']?.toString() ?? 'Siswa Arrava';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 390;
          final isVeryCompact = constraints.maxWidth < 340;

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopProfileRow(
                isCompact: isCompact,
                isVeryCompact: isVeryCompact,
                studentName: studentName,
                jenjangName: jenjangName,
                currentRank: currentRank,
                kuisLulus: kuisLulus,
                modulCount: effectiveModulCount,
              ),
              _buildRankExpCard(
                isCompact: isCompact,
                currentRank: currentRank,
                currentBadgeUrl: currentBadgeUrl,
                currentPoints: currentPoints,
                nextRank: nextRank,
                nextPoints: nextPoints,
                pointsNeeded: pointsNeeded,
                percent: percent,
                isMax: isMax,
              ),
              _buildBottomActionRow(
                isCompact: isCompact,
                studentName: studentName,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopProfileRow({
    required bool isCompact,
    required bool isVeryCompact,
    required String studentName,
    required String jenjangName,
    required String currentRank,
    required dynamic kuisLulus,
    required dynamic modulCount,
  }) {
    final avatarRadius = isCompact ? 20.0 : 23.0;
    final nextHeroShort = _isGalaksi ? 'Samudra' : 'Galaksi';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Builder(
                builder: (context) {
                  final rawPhoto = (user?['foto_profil'] ??
                          user?['foto_profil_url'] ??
                          user?['foto'])
                      ?.toString();
                  final resolvedPhoto = ApiConstants.resolveMediaUrl(rawPhoto);
                  if (resolvedPhoto != null && resolvedPhoto.isNotEmpty) {
                    return Image.network(
                      resolvedPhoto,
                      width: avatarRadius * 2,
                      height: avatarRadius * 2,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, _) {
                        debugPrint(
                          '[HERO AVATAR ERROR] Failed loading: $resolvedPhoto | Error: $error',
                        );
                        return _buildAvatarFallback(studentName, avatarRadius);
                      },
                    );
                  }
                  return _buildAvatarFallback(studentName, avatarRadius);
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isCompact ? 13.5 : 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5.5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF6EE7B7)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 9.5,
                          color: Color(0xFF059669),
                        ),
                        const SizedBox(width: 2.5),
                        Text(
                          jenjangName,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                runSpacing: 3,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Level: $currentRank',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    '• $kuisLulus Kuis',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.95),
                      shadows: const [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  if (!isVeryCompact)
                    Text(
                      '• $modulCount Modul',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.95),
                        shadows: const [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  if (onToggleHeroTheme != null)
                    GestureDetector(
                      onTap: isHeroSwitching ? null : onToggleHeroTheme,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _isGalaksi
                              ? const Color(0xB30F172A)
                              : Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isGalaksi
                                ? const Color(0x597DD3FC)
                                : Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isHeroSwitching)
                              const SizedBox(
                                width: 9,
                                height: 9,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Colors.white,
                                ),
                              )
                            else
                              Icon(
                                _isGalaksi
                                    ? Icons.water_rounded
                                    : Icons.auto_awesome_rounded,
                                size: 10.5,
                                color: _isGalaksi
                                    ? const Color(0xFFE0F2FE)
                                    : Colors.white,
                              ),
                            const SizedBox(width: 3),
                            Text(
                              isVeryCompact
                                  ? 'Hero: $nextHeroShort'
                                  : 'Ganti Hero ($nextHeroShort)',
                              style: TextStyle(
                                fontSize: 9.2,
                                fontWeight: FontWeight.w800,
                                color: _isGalaksi
                                    ? const Color(0xFFE0F2FE)
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (onNotificationTap != null) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onNotificationTap,
            child: Consumer<NotificationProvider>(
              builder: (context, notifProvider, _) {
                final unread = notifProvider.unreadCount;
                return Container(
                  padding: const EdgeInsets.all(5.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        size: 17,
                        color: Color(0xFF12233F),
                      ),
                      if (unread > 0)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              unread > 9 ? '9+' : '$unread',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 7.5,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatarFallback(String name, double radius) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isGalaksi
              ? const [Color(0xFF312E81), Color(0xFF38BDF8)]
              : const [Color(0xFF007FBE), Color(0xFF51CDF4)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'S',
        style: TextStyle(
          fontSize: radius * 0.9,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRankExpCard({
    required bool isCompact,
    required String currentRank,
    required String? currentBadgeUrl,
    required int currentPoints,
    required String nextRank,
    required int nextPoints,
    required int pointsNeeded,
    required int percent,
    required bool isMax,
  }) {
    final badgeResolved = ApiConstants.resolveMediaUrl(currentBadgeUrl);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 12,
        vertical: isCompact ? 7 : 8.5,
      ),
      decoration: BoxDecoration(
        color: _isGalaksi
            ? const Color(0x8C05060F)
            : Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isGalaksi
              ? const Color(0x407DD3FC)
              : Colors.white.withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PERINGKAT & EXP',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              GestureDetector(
                onTap: onLeaderboardTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (badgeResolved != null && badgeResolved.isNotEmpty)
                        Image.network(
                          badgeResolved,
                          width: 13,
                          height: 13,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Text(
                            '★',
                            style: TextStyle(
                              color: Color(0xFFD97706),
                              fontSize: 11,
                            ),
                          ),
                        )
                      else
                        const Text(
                          '★',
                          style: TextStyle(
                            color: Color(0xFFD97706),
                            fontSize: 11,
                          ),
                        ),
                      const SizedBox(width: 3),
                      Text(
                        currentRank,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatNumber(currentPoints),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isCompact ? 20 : 23,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'EXP',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFDE047),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Flexible(
                child: isMax
                    ? const Text(
                        'Tingkat Tertinggi 👑',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6EE7B7),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                              children: [
                                const TextSpan(text: 'Menuju '),
                                TextSpan(
                                  text: nextRank,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${_formatNumber(currentPoints)} / ${_formatNumber(nextPoints)}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Image.asset(
                'assets/widget/exp.png',
                width: 17,
                height: 17,
                filterQuality: FilterQuality.none,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 8.5,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (percent / 100).clamp(0.02, 1.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFBBF24),
                              Color(0xFFFB923C),
                              Color(0xFFF59E0B),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 32,
                child: Text(
                  '$percent%',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFDE047),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5.5),
          Container(
            padding: const EdgeInsets.only(top: 4.5),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: isMax
                      ? const Text(
                          'Hebat! Semua tingkat terbuka.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6EE7B7),
                          ),
                        )
                      : RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 9.5,
                              color: Colors.white.withValues(alpha: 0.90),
                            ),
                            children: [
                              const TextSpan(text: 'Sisa '),
                              TextSpan(
                                text: '${_formatNumber(pointsNeeded)} EXP',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const TextSpan(text: ' lagi'),
                            ],
                          ),
                        ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onLeaderboardTap,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat leaderboard',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFDE047),
                        ),
                      ),
                      SizedBox(width: 2),
                      Text(
                        '→',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFDE047),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionRow({
    required bool isCompact,
    required String studentName,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Halo, $studentName 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isCompact ? 12.5 : 13.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Jelajahi materi & raih ranking teratas!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.90),
                    shadows: const [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onExploreTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 12,
                    color: Color(0xFF007FBE),
                  ),
                  SizedBox(width: 3.5),
                  Text(
                    'Belajar',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF007FBE),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onQuizTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF007FBE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00628E)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF00628E),
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                  SizedBox(width: 3.5),
                  Text(
                    'Kuis',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
