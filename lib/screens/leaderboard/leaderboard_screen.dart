import 'package:flutter/material.dart';
import '../../core/constants/api_constants.dart';
import '../../services/dashboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final int? initialJenjangId;

  const LeaderboardScreen({
    super.key,
    this.initialJenjangId,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedJenjangId = 0; // 0 = Semua, 1 = SD, 2 = SMP, 3 = SMA

  List<Map<String, dynamic>> _leaderboard = [];
  Map<String, dynamic>? _myRank;

  static const Color _primary = Color(0xFF2563EB);
  static const Color _gold = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _selectedJenjangId = widget.initialJenjangId ?? 0;
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await DashboardService.fetchLeaderboard(
        jenjangId: _selectedJenjangId,
      );

      if (mounted) {
        setState(() {
          _leaderboard = (data['leaderboard'] as List?)
                  ?.cast<Map<String, dynamic>>() ??
              [];
          _myRank = data['my_rank'] as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _onSelectJenjang(int jenjangId) {
    if (_selectedJenjangId == jenjangId) return;
    setState(() {
      _selectedJenjangId = jenjangId;
    });
    _fetchLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.emoji_events_rounded, color: _gold, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Papan Peringkat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Top Pelajar Terbaik Arrava',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // JENJANG FILTER CHIPS BAR
          _buildJenjangFilterBar(),

          // CONTENT LIST / LOADING / ERROR
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _primary),
                  )
                : _errorMessage != null
                    ? _buildErrorView()
                    : RefreshIndicator(
                        onRefresh: _fetchLeaderboard,
                        color: _primary,
                        child: _leaderboard.isEmpty
                            ? _buildEmptyView()
                            : ListView(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                                children: [
                                  // PODIUM TOP 3
                                  if (_leaderboard.isNotEmpty)
                                    _buildPodiumSection(),

                                  const SizedBox(height: 18),

                                  // RANKING LIST #4 ONWARDS
                                  if (_leaderboard.length > 3) ...[
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                      child: Text(
                                        'Peringkat Selanjutnya',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ..._leaderboard.skip(3).map((item) => _buildRankItem(item)),
                                  ],
                                ],
                              ),
                      ),
          ),
        ],
      ),
      bottomSheet: _myRank != null ? _buildMyRankBar(_myRank!) : null,
    );
  }

  Widget _buildJenjangFilterBar() {
    final filters = [
      {'id': 0, 'label': 'Semua Jenjang'},
      {'id': 1, 'label': 'SD'},
      {'id': 2, 'label': 'SMP'},
      {'id': 3, 'label': 'SMA'},
    ];

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final id = f['id'] as int;
            final isSelected = _selectedJenjangId == id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(f['label'] as String),
                selected: isSelected,
                onSelected: (_) => _onSelectJenjang(id),
                selectedColor: _primary,
                checkmarkColor: Colors.white,
                showCheckmark: false,
                labelStyle: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
                backgroundColor: const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? _primary : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPodiumSection() {
    final first = _leaderboard.isNotEmpty ? _leaderboard[0] : null;
    final second = _leaderboard.length > 1 ? _leaderboard[1] : null;
    final third = _leaderboard.length > 2 ? _leaderboard[2] : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🏆 Puncak Prestasi 🏆',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2ND PLACE
              if (second != null)
                Expanded(
                  child: _buildPodiumCol(
                    student: second,
                    rank: 2,
                    badgeEmoji: '🥈',
                    pillarColor: const Color(0xFFE2E8F0),
                    pillarHeight: 100,
                    avatarSize: 26,
                  ),
                )
              else
                const Spacer(),

              // 1ST PLACE (TALLEST)
              if (first != null)
                Expanded(
                  child: _buildPodiumCol(
                    student: first,
                    rank: 1,
                    badgeEmoji: '👑',
                    pillarColor: const Color(0xFFFEF3C7),
                    pillarHeight: 125,
                    avatarSize: 32,
                    isChampion: true,
                  ),
                )
              else
                const Spacer(),

              // 3RD PLACE
              if (third != null)
                Expanded(
                  child: _buildPodiumCol(
                    student: third,
                    rank: 3,
                    badgeEmoji: '🥉',
                    pillarColor: const Color(0xFFFED7AA),
                    pillarHeight: 85,
                    avatarSize: 24,
                  ),
                )
              else
                const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumCol({
    required Map<String, dynamic> student,
    required int rank,
    required String badgeEmoji,
    required Color pillarColor,
    required double pillarHeight,
    required double avatarSize,
    bool isChampion = false,
  }) {
    final nama = student['nama']?.toString() ?? 'Siswa';
    final pts = student['total_poin']?.toString() ?? '0';
    final photoUrl = ApiConstants.resolveMediaUrl(student['foto_profil']?.toString());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown / Badge emoji
        Text(badgeEmoji, style: TextStyle(fontSize: isChampion ? 24 : 18)),
        const SizedBox(height: 4),

        // Avatar
        CircleAvatar(
          radius: avatarSize + (isChampion ? 3 : 1),
          backgroundColor: isChampion ? _gold : Colors.white,
          child: CircleAvatar(
            radius: avatarSize,
            backgroundColor: const Color(0xFFDBEAFE),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? Text(
                    nama.isNotEmpty ? nama[0].toUpperCase() : 'S',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _primary,
                      fontSize: avatarSize * 0.8,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 6),

        // Name
        Text(
          nama,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isChampion ? 12.5 : 11,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),

        // XP
        Container(
          margin: const EdgeInsets.only(top: 2, bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '⚡ $pts XP',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFEF08A),
            ),
          ),
        ),

        // Pillar Base
        Container(
          width: double.infinity,
          height: pillarHeight,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: pillarColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: isChampion ? 22 : 18,
                fontWeight: FontWeight.w900,
                color: isChampion ? const Color(0xFFB45309) : const Color(0xFF475569),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankItem(Map<String, dynamic> item) {
    final rank = item['rank']?.toString() ?? '-';
    final nama = item['nama']?.toString() ?? 'Siswa';
    final jenjang = item['jenjang']?.toString() ?? 'SD';
    final tier = item['tier']?.toString() ?? 'Starter';
    final pts = item['total_poin']?.toString() ?? '0';
    final photoUrl = ApiConstants.resolveMediaUrl(item['foto_profil']?.toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          CircleAvatar(
            radius: 19,
            backgroundColor: const Color(0xFFEFF6FF),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? Text(
                    nama.isNotEmpty ? nama[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _primary,
                      fontSize: 13,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Name, Jenjang & Tier
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        jenjang,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tier,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // XP Points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Text(
              '⚡ $pts XP',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB45309),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRankBar(Map<String, dynamic> myRank) {
    final rank = myRank['rank']?.toString() ?? '-';
    final nama = myRank['nama']?.toString() ?? 'Kamu';
    final pts = myRank['total_poin']?.toString() ?? '0';
    final tier = myRank['tier']?.toString() ?? 'Starter';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFDBEAFE), width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primary, Color(0xFF1D4ED8)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Peringkat Kamu',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tier,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Text(
                '⚡ $pts XP',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.military_tech_outlined, size: 56, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            const Text(
              'Belum Ada Data Peringkat',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kerjakan kuis dan modul pembelajaran untuk mengumpulkan XP dan memuncaki papan peringkat!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Gagal memuat papan peringkat.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _fetchLeaderboard,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
