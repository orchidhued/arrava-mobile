import 'package:flutter/material.dart';

import '../../shared/widgets/app_header.dart';
import 'create_quiz_page.dart';
import 'quiz_preview_player_page.dart';

class ManageQuizPage extends StatefulWidget {
  const ManageQuizPage({super.key});

  @override
  State<ManageQuizPage> createState() => _ManageQuizPageState();
}

class _ManageQuizPageState extends State<ManageQuizPage> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedJenjang = 'Semua';
  String _selectedDifficulty = 'Semua';
  String _selectedSort = 'terbaru';

  final List<_QuizItem> _allQuizzes = [
    _QuizItem(
      id: 1,
      title: 'Evaluasi Algoritma & Logika Pemrograman',
      module: 'Modul 1: Pengantar Algoritma & Flowchart',
      description:
          'Kuis interaktif untuk menguji pemahaman konsep percabangan, perulangan, dan analisis algoritma dasar.',
      jenjang: 'SMA / MA / SMK Sederajat',
      difficulty: 'Mudah',
      mode: 'Wayground',
      durationSeconds: 20,
      questionsCount: 20,
      totalPoints: 100,
      participantsCount: 128,
      requiresToken: false,
      isExpired: false,
      status: 'Tersedia',
      coverGradient: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
    ),
    _QuizItem(
      id: 2,
      title: 'UI/UX Design System Mastery 360',
      module: 'Modul 2: Design Token & Atomic Components',
      description:
          'Evaluasi pemahaman design system, typography scale, color contrast, serta aksesibilitas antarmuka pengguna.',
      jenjang: 'Perguruan Tinggi / Umum',
      difficulty: 'Sedang',
      mode: 'Wayground',
      durationSeconds: 30,
      questionsCount: 25,
      totalPoints: 125,
      participantsCount: 96,
      requiresToken: true,
      tokenCode: 'UX2026',
      isExpired: false,
      status: 'Tersedia',
      coverGradient: [Color(0xFF46178F), Color(0xFF7C3AED)],
    ),
    _QuizItem(
      id: 3,
      title: 'Fullstack React & Node.js API Integration',
      module: 'Modul 3: REST API & State Management',
      description:
          'Uji pemahaman arsitektur REST, async-await, authentication JWT, dan pengelolaan state global.',
      jenjang: 'Perguruan Tinggi / Umum',
      difficulty: 'Sulit',
      mode: 'Kuis Biasa',
      durationSeconds: 45 * 60,
      questionsCount: 30,
      totalPoints: 150,
      participantsCount: 84,
      requiresToken: true,
      tokenCode: 'REACT99',
      isExpired: false,
      status: 'Tersedia',
      coverGradient: [Color(0xFF0F172A), Color(0xFF2563EB)],
    ),
    _QuizItem(
      id: 4,
      title: 'Dasar Logika Matematika & Algoritma',
      module: 'Modul Dasar: Logika Proposisi & Tabel Kebenaran',
      description:
          'Latihan soal pengantar logika dasar dan penalaran analitis untuk siswa sekolah menengah.',
      jenjang: 'SMP / MTs',
      difficulty: 'Mudah',
      mode: 'Wayground',
      durationSeconds: 20,
      questionsCount: 15,
      totalPoints: 75,
      participantsCount: 62,
      requiresToken: false,
      isExpired: false,
      status: 'Tersedia',
      coverGradient: [Color(0xFF065F46), Color(0xFF10B981)],
    ),
    _QuizItem(
      id: 5,
      title: 'Data Analytics dengan Python & SQL',
      module: 'Modul 4: Data Wrangling & Query Analysis',
      description:
          'Evaluasi pembersihan data menggunakan pandas, agregasi database SQL, dan visualisasi dasar.',
      jenjang: 'Perguruan Tinggi / Umum',
      difficulty: 'Sedang',
      mode: 'Wayground',
      durationSeconds: 25,
      questionsCount: 25,
      totalPoints: 100,
      participantsCount: 0,
      requiresToken: false,
      isExpired: true,
      status: 'Kadaluarsa',
      coverGradient: [Color(0xFF7C2D12), Color(0xFFEA580C)],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_QuizItem> get _filteredQuizzes {
    final query = _searchController.text.toLowerCase().trim();

    var list = _allQuizzes.where((quiz) {
      final matchQuery = query.isEmpty ||
          quiz.title.toLowerCase().contains(query) ||
          quiz.module.toLowerCase().contains(query);

      final matchJenjang =
          _selectedJenjang == 'Semua' || quiz.jenjang == _selectedJenjang;

      final matchDifficulty = _selectedDifficulty == 'Semua' ||
          quiz.difficulty == _selectedDifficulty;

      return matchQuery && matchJenjang && matchDifficulty;
    }).toList();

    if (_selectedSort == 'terlama') {
      list = list.reversed.toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredQuizzes;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Kelola Kuis Pembelajaran',
              onNotificationTap: () {},
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  // Header Title & Create Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kelola Kuis Pembelajaran',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Daftar kuis interaktif yang tersedia di platform',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateQuizPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text(
                          'Buat Quiz',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Kahoot 360 Style Hero Banner
                  _buildHeroBanner(),

                  const SizedBox(height: 16),

                  // Filter & Search Section
                  _buildFilterSection(),

                  const SizedBox(height: 16),

                  // Count indicator
                  Row(
                    children: [
                      Text(
                        'Semua Quiz (${filtered.length})',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      if (_selectedJenjang != 'Semua' ||
                          _selectedDifficulty != 'Semua' ||
                          _searchController.text.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _selectedJenjang = 'Semua';
                              _selectedDifficulty = 'Semua';
                              _selectedSort = 'terbaru';
                            });
                          },
                          icon: const Icon(Icons.refresh, size: 14),
                          label: const Text(
                            'Reset Filter',
                            style: TextStyle(fontSize: 11),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF64748B),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // List of Cards or Empty State
                  if (filtered.isEmpty)
                    _buildEmptyState()
                  else
                    ...filtered.map(
                      (quiz) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildQuizCard(quiz),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Hero Banner Kahoot 360
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF46178F), // Kahoot purple
            Color(0xFF1368CE), // Kahoot blue
            Color(0xFF0B4FB3), // Kahoot deep navy
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF46178F).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background subtle geometry
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.12,
              child: Icon(
                Icons.change_history,
                size: 160,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            right: 80,
            top: -20,
            child: Opacity(
              opacity: 0.10,
              child: Icon(
                Icons.diamond_outlined,
                size: 110,
                color: Colors.white,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '✨',
                        style: TextStyle(fontSize: 11),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'EDITOR INTERAKTIF KAHOOT! 360 STYLE',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Color(0xFFFEF08A),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Buat Pengalaman Belajar Seru untuk Siswa',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Tambahkan soal pilihan ganda 4 warna, timer detik, serta kunci jawaban langsung dalam satu tampilan visual interaktif.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateQuizPage(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.bolt,
                    size: 16,
                    color: Color(0xFF0F172A),
                  ),
                  label: const Text(
                    'Buka Editor Quiz Baru',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFACC15), // Kahoot yellow
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Filter & Search Bar
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Box
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cari kuis atau materi...',
              hintStyle: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(
                Icons.search,
                size: 18,
                color: Color(0xFF64748B),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Dropdowns Row
          Row(
            children: [
              // Jenjang Filter
              Expanded(
                child: _buildDropdownFilter(
                  label: 'Jenjang',
                  value: _selectedJenjang,
                  items: const [
                    'Semua',
                    'SD / MI',
                    'SMP / MTs',
                    'SMA / MA / SMK Sederajat',
                    'Perguruan Tinggi / Umum',
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedJenjang = val);
                  },
                ),
              ),

              const SizedBox(width: 8),

              // Kesulitan Filter
              Expanded(
                child: _buildDropdownFilter(
                  label: 'Kesulitan',
                  value: _selectedDifficulty,
                  items: const ['Semua', 'Mudah', 'Sedang', 'Sulit'],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDifficulty = val);
                  },
                ),
              ),

              const SizedBox(width: 8),

              // Urutkan Filter
              Expanded(
                child: _buildDropdownFilter(
                  label: 'Urutkan',
                  value: _selectedSort,
                  items: const ['terbaru', 'terlama'],
                  itemLabels: const {
                    'terbaru': 'Terbaru',
                    'terlama': 'Terlama',
                  },
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSort = val);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<String> items,
    Map<String, String>? itemLabels,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          icon: const Icon(
            Icons.expand_more,
            size: 16,
            color: Color(0xFF94A3B8),
          ),
          items: items.map((item) {
            final display = itemLabels?[item] ?? item;
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                display,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // 3. Quiz Card Kahoot 360 Style
  Widget _buildQuizCard(_QuizItem quiz) {
    Color difficultyColor;
    Color difficultyBg;
    if (quiz.difficulty == 'Mudah') {
      difficultyColor = const Color(0xFF047857);
      difficultyBg = const Color(0xFFD1FAE5);
    } else if (quiz.difficulty == 'Sedang') {
      difficultyColor = const Color(0xFFB45309);
      difficultyBg = const Color(0xFFFEF3C7);
    } else {
      difficultyColor = const Color(0xFFBE123C);
      difficultyBg = const Color(0xFFFFE4E6);
    }

    final bool isWayground = quiz.mode == 'Wayground';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: quiz.isExpired
              ? const Color(0xFFE2E8F0)
              : const Color(0xFFCBD5E1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header with Cover Gradient & Badges
          Container(
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: quiz.coverGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(17),
                topRight: Radius.circular(17),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Jenjang & Status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '🎓 ${quiz.jenjang}',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: quiz.isExpired
                            ? const Color(0xFFBE123C)
                            : const Color(0xFF059669),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        quiz.isExpired ? 'Kadaluarsa' : 'Tersedia',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom Row on Cover: Mode & Token
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: isWayground
                            ? const Color(0xFFFACC15)
                            : Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isWayground ? '⚡ Wayground' : '⏱️ Kuis Biasa',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: quiz.requiresToken
                            ? const Color(0xFFEDE9FE)
                            : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        quiz.requiresToken ? '🔒 Perlu Token' : '🔓 Terbuka',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: quiz.requiresToken
                              ? const Color(0xFF5B21B6)
                              : const Color(0xFF166534),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Body Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        quiz.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: difficultyBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        quiz.difficulty,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: difficultyColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  quiz.module,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  quiz.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 12),
                Divider(height: 1, color: const Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // Statistics Row
                Row(
                  children: [
                    _buildMetaPill(
                      Icons.help_outline,
                      '${quiz.questionsCount} Soal',
                    ),
                    const SizedBox(width: 12),
                    _buildMetaPill(
                      Icons.timer_outlined,
                      isWayground
                          ? '${quiz.durationSeconds}s/Soal'
                          : '${(quiz.durationSeconds / 60).round()}m Total',
                    ),
                    const SizedBox(width: 12),
                    _buildMetaPill(
                      Icons.military_tech_outlined,
                      '${quiz.totalPoints} Poin',
                      color: const Color(0xFFD97706),
                    ),
                    const Spacer(),
                    _buildMetaPill(
                      Icons.group_outlined,
                      '${quiz.participantsCount}',
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Action Buttons Row
                Row(
                  children: [
                    // Preview Button (Kahoot interactive play preview)
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: () => _showPreviewSheet(quiz),
                          icon: const Icon(
                            Icons.visibility_outlined,
                            size: 15,
                          ),
                          label: const Text(
                            'Pratinjau Kuis',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF46178F),
                            side: const BorderSide(color: Color(0xFFDDD6FE)),
                            backgroundColor: const Color(0xFFF5F3FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Edit Button
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateQuizPage(),
                            ),
                          );
                        },
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 17,
                          color: Color(0xFF1D4ED8),
                        ),
                        tooltip: 'Edit Quiz',
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Delete Button
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECDD3)),
                      ),
                      child: IconButton(
                        onPressed: () => _confirmDelete(quiz),
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 17,
                          color: Color(0xFFE11D48),
                        ),
                        tooltip: 'Hapus Quiz',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaPill(IconData icon, String text, {Color? color}) {
    final c = color ?? const Color(0xFF64748B);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: c,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('🧩', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tidak Ada Kuis Ditemukan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Coba ubah kata kunci pencarian atau reset filter di atas.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  // Preview BottomSheet similar to quiz-detail.blade.php
  void _showPreviewSheet(_QuizItem quiz) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('👁️', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          quiz.module,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Specs Grid (4 boxes)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.2,
                children: [
                  _buildSpecBox('📋 JUMLAH SOAL', '${quiz.questionsCount} Soal'),
                  _buildSpecBox(
                    '⏱️ WAKTU KUIS',
                    quiz.mode == 'Wayground'
                        ? '${quiz.durationSeconds} Detik/Soal'
                        : '${(quiz.durationSeconds / 60).round()} Menit Total',
                  ),
                  _buildSpecBox('🏆 MAKSIMAL POIN', '${quiz.totalPoints} Poin'),
                  _buildSpecBox(
                    '⚡ MODE SISTEM',
                    quiz.mode == 'Wayground' ? 'Wayground' : 'Kuis Biasa',
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Description
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  quiz.description,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Start Play Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // close sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizPreviewPlayerPage(
                          title: quiz.title,
                          jenjang: quiz.jenjang,
                          difficulty: quiz.difficulty,
                          mode: quiz.mode,
                          totalQuestions: quiz.questionsCount,
                          totalPoints: quiz.totalPoints,
                          timeLimitPerQuestion: quiz.durationSeconds,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text(
                    'Mulai Pratinjau Kuis Interaktif ⚡',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF46178F), // Kahoot purple
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(_QuizItem quiz) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Hapus Quiz?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus kuis "${quiz.title}"? Tindakan ini tidak dapat dibatalkan.',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _allQuizzes.removeWhere((item) => item.id == quiz.id);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Kuis "${quiz.title}" berhasil dihapus.'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}

class _QuizItem {
  final int id;
  final String title;
  final String module;
  final String description;
  final String jenjang;
  final String difficulty;
  final String mode;
  final int durationSeconds;
  final int questionsCount;
  final int totalPoints;
  final int participantsCount;
  final bool requiresToken;
  final String? tokenCode;
  final bool isExpired;
  final String status;
  final List<Color> coverGradient;

  _QuizItem({
    required this.id,
    required this.title,
    required this.module,
    required this.description,
    required this.jenjang,
    required this.difficulty,
    required this.mode,
    required this.durationSeconds,
    required this.questionsCount,
    required this.totalPoints,
    required this.participantsCount,
    required this.requiresToken,
    this.tokenCode,
    required this.isExpired,
    required this.status,
    required this.coverGradient,
  });
}
