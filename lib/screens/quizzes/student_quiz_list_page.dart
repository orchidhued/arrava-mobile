import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/quizzes/models/quiz_model.dart';
import '../../admin/quizzes/providers/quiz_provider.dart';
import 'student_quiz_player_page.dart';

class StudentQuizListPage extends StatefulWidget {
  const StudentQuizListPage({super.key});

  @override
  State<StudentQuizListPage> createState() => _StudentQuizListPageState();
}

class _StudentQuizListPageState extends State<StudentQuizListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter =
      'Semua'; // 'Semua', 'Belum Dikerjakan', 'Lulus', 'Belum Lulus'
  final String _selectedJenjang = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().fetchQuizzes(status: 'tersedia');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QuizModel> _filterQuizzes(List<QuizModel> list) {
    final query = _searchController.text.toLowerCase().trim();
    final selJenjang = _selectedJenjang.toLowerCase().trim();

    return list.where((quiz) {
      if (quiz.isDraft) {
        return false; // Siswa hanya melihat kuis yang sudah dipublikasikan
      }

      final matchQuery =
          query.isEmpty ||
          quiz.judul.toLowerCase().contains(query) ||
          (quiz.deskripsi?.toLowerCase().contains(query) ?? false);

      final quizJenjang = (quiz.namaJenjang ?? '').toLowerCase().trim();
      final matchJenjang =
          _selectedJenjang == 'Semua' ||
          quizJenjang == selJenjang ||
          selJenjang.contains(quizJenjang) ||
          quizJenjang.contains(selJenjang);

      bool matchStatus = true;
      if (_selectedStatusFilter == 'Belum Dikerjakan') {
        matchStatus = !quiz.hasTaken;
      } else if (_selectedStatusFilter == 'Lulus') {
        matchStatus = quiz.isPassed;
      } else if (_selectedStatusFilter == 'Belum Lulus') {
        matchStatus = quiz.hasTaken && !quiz.isPassed;
      }

      return matchQuery && matchJenjang && matchStatus;
    }).toList();
  }

  void _showQuizDetailSheet(QuizModel quiz) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final tokenController = TextEditingController();
        bool isVerifying = false;
        String? tokenError;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF46178F),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Arrava 360',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: quiz.isWayground
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: quiz.isWayground
                                  ? const Color(0xFFBFDBFE)
                                  : const Color(0xFFBBF7D0),
                            ),
                          ),
                          child: Text(
                            quiz.isWayground ? '⚡ Wayground' : '⏱️ Kuis Biasa',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: quiz.isWayground
                                  ? const Color(0xFF1D4ED8)
                                  : const Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      quiz.judul,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (quiz.deskripsi != null &&
                        quiz.deskripsi!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        quiz.deskripsi!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDetailStat(
                            label: 'Total Soal',
                            value: '${quiz.questionsCount} Soal',
                          ),
                          Container(
                            width: 1,
                            height: 28,
                            color: const Color(0xFFCBD5E1),
                          ),
                          _buildDetailStat(
                            label: 'Total Poin',
                            value: '${quiz.totalPoints} Poin',
                          ),
                          Container(
                            width: 1,
                            height: 28,
                            color: const Color(0xFFCBD5E1),
                          ),
                          _buildDetailStat(
                            label: 'Mode Waktu',
                            value: quiz.isWayground
                                ? 'Per Soal'
                                : '${quiz.durasiTotalMenit ?? 30} Mnt',
                          ),
                        ],
                      ),
                    ),
                    if (quiz.requiresToken) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Token Kuis Diperlukan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: tokenController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'Masukkan 6 digit token dari guru...',
                          prefixIcon: const Icon(
                            Icons.key,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          errorText: tokenError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: isVerifying
                            ? null
                            : () async {
                                if (quiz.requiresToken) {
                                  final entered = tokenController.text.trim();
                                  if (entered.isEmpty) {
                                    setSheetState(
                                      () => tokenError =
                                          'Token kuis wajib diisi!',
                                    );
                                    return;
                                  }

                                  setSheetState(() {
                                    isVerifying = true;
                                    tokenError = null;
                                  });

                                  final provider = context.read<QuizProvider>();
                                  final valid = await provider.verifyToken(
                                    quiz.idQuiz,
                                    entered,
                                  );

                                  setSheetState(() => isVerifying = false);

                                  if (!valid) {
                                    setSheetState(
                                      () => tokenError =
                                          'Token kuis salah. Coba lagi!',
                                    );
                                    return;
                                  }

                                  if (!ctx.mounted || !context.mounted) return;
                                  Navigator.pop(ctx); // Close sheet
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          StudentQuizPlayerPage(quiz: quiz),
                                    ),
                                  );
                                } else {
                                  Navigator.pop(ctx);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          StudentQuizPlayerPage(quiz: quiz),
                                    ),
                                  );
                                }
                              },
                        icon: isVerifying
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.play_arrow, size: 20),
                        label: Text(
                          isVerifying
                              ? 'Memverifikasi...'
                              : 'Mulai Kerjakan Kuis 🚀',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailStat({required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final quizzes = _filterQuizzes(quizProvider.quizzes);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Kuis Interaktif Pembelajaran',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Filter Tabs (Semua, Belum Dikerjakan, Lulus, Belum Lulus)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari kuis pembelajaran...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: Color(0xFF94A3B8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        [
                          'Semua',
                          'Belum Dikerjakan',
                          'Lulus',
                          'Belum Lulus',
                        ].map((status) {
                          final isSelected = _selectedStatusFilter == status;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(status),
                              selected: isSelected,
                              onSelected: (_) => setState(
                                () => _selectedStatusFilter = status,
                              ),
                              selectedColor: const Color(0xFF2563EB),
                              labelStyle: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF475569),
                              ),
                              backgroundColor: const Color(0xFFF1F5F9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Quiz Cards List
          Expanded(
            child: quizProvider.isLoading && quizProvider.quizzes.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : quizProvider.error != null && quizProvider.quizzes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            size: 48,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Gagal Memuat Kuis',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            quizProvider.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => context
                                .read<QuizProvider>()
                                .fetchQuizzes(status: 'tersedia'),
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : quizzes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.quiz_outlined,
                          size: 48,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum Ada Kuis Tersedia',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Silakan periksa kembali nanti atau hubungi guru Anda.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () => context
                              .read<QuizProvider>()
                              .fetchQuizzes(status: 'tersedia'),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => context.read<QuizProvider>().fetchQuizzes(
                      status: 'tersedia',
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: quizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = quizzes[index];
                        return _buildQuizCard(quiz);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(QuizModel quiz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient Header
          Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: quiz.isWayground
                    ? [
                        const Color(0xFF2563EB),
                        const Color(0xFF1D4ED8),
                        const Color(0xFF46178F),
                      ]
                    : [
                        const Color(0xFF059669),
                        const Color(0xFF047857),
                        const Color(0xFF065F46),
                      ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    quiz.isWayground ? '⚡ Wayground 360' : '⏱️ Kuis Biasa',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (quiz.hasTaken)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: quiz.isPassed
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      quiz.isPassed ? '🎉 Lulus' : '💪 Belum Lulus',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Belum Dikerjakan',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                Text(
                  quiz.judul,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (quiz.deskripsi != null && quiz.deskripsi!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    quiz.deskripsi!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildBadge(
                      Icons.help_outline,
                      '${quiz.questionsCount} Soal',
                    ),
                    const SizedBox(width: 8),
                    _buildBadge(Icons.star_outline, '${quiz.totalPoints} Poin'),
                    const Spacer(),
                    if (quiz.requiresToken)
                      const Row(
                        children: [
                          Icon(Icons.lock, size: 13, color: Color(0xFFD97706)),
                          SizedBox(width: 3),
                          Text(
                            'Token',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFD97706),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => _showQuizDetailSheet(quiz),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: quiz.hasTaken
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFF2563EB),
                      foregroundColor: quiz.hasTaken
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      elevation: quiz.hasTaken ? 0 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      quiz.hasTaken
                          ? 'Kerjakan Ulang Kuis'
                          : 'Mulai Kerjakan Kuis ⚡',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
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

  Widget _buildBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
