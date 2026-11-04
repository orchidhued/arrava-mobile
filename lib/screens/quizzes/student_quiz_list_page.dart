import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/quizzes/models/quiz_model.dart';
import '../../admin/quizzes/providers/quiz_provider.dart';
import '../../services/auth_service.dart';
import '../../core/constants/api_constants.dart';
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
  int? _userJenjangId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuizzes();
    });
  }

  Future<void> _loadQuizzes() async {
    final jenjangStr = await AuthService.getJenjang();
    if (mounted) {
      setState(() {
        _userJenjangId = int.tryParse(jenjangStr ?? '');
      });
      context.read<QuizProvider>().fetchQuizzes(
        status: 'tersedia',
        jenjang: _userJenjangId,
      );
    }
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
                    // Cover Preview di Modal Detail Sheet
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 130,
                        width: double.infinity,
                        child: _buildCoverImage(quiz, height: 130),
                      ),
                    ),
                    const SizedBox(height: 14),
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
                            onPressed: _loadQuizzes,
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
                          onPressed: _loadQuizzes,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadQuizzes,
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

  /// Widget penampil cover gambar kuis / foto soal dengan fallback aset resmi
  Widget _buildCoverImage(QuizModel quiz, {double height = 160}) {
    final String? resolvedCoverUrl =
        ApiConstants.resolveMediaUrl(quiz.effectiveCoverUrl);

    Widget imageWidget;
    if (resolvedCoverUrl != null &&
        !resolvedCoverUrl.contains('latarQuizDefault.webp') &&
        (resolvedCoverUrl.startsWith('http://') ||
            resolvedCoverUrl.startsWith('https://'))) {
      imageWidget = Image.network(
        resolvedCoverUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/widget/latarQuizDefault.webp',
          fit: BoxFit.cover,
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFF0F172A),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF38BDF8),
                ),
              ),
            ),
          );
        },
      );
    } else {
      imageWidget = Image.asset(
        'assets/widget/latarQuizDefault.webp',
        fit: BoxFit.cover,
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: imageWidget,
    );
  }

  Widget _buildQuizCard(QuizModel quiz) {
    Color tingkatColor;
    switch ((quiz.namaTingkat ?? '').toLowerCase()) {
      case 'mudah':
        tingkatColor = const Color(0xFF10B981);
        break;
      case 'sedang':
        tingkatColor = const Color(0xFFF59E0B);
        break;
      case 'sulit':
        tingkatColor = const Color(0xFFEF4444);
        break;
      default:
        tingkatColor = const Color(0xFF64748B);
    }

    final hasQuestionPhoto = quiz.firstSoalFoto != null;

    final questionTypes = quiz.soal
        .map((s) => s.jenisSoal.apiValue == 'true_false'
            ? 'Benar/Salah'
            : (s.jenisSoal.apiValue == 'isian_singkat'
                ? 'Isian Singkat'
                : 'Pilihan Ganda'))
        .toSet()
        .toList();

    final isCompletedAndPassed = quiz.hasTaken && quiz.isPassed;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompletedAndPassed
              ? const Color(0xFF86EFAC).withValues(alpha: 0.8)
              : const Color(0xFFE2E8F0),
          width: isCompletedAndPassed ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showQuizDetailSheet(quiz),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================================================
              // 1. COVER / THUMBNAIL AREA (160px) DENGAN FOTO SOAL / COVER
              // =========================================================
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image (Foto Soal / Cover / Latar Default)
                    _buildCoverImage(quiz, height: 160),

                    // Gradien Bayangan Lembut agar Badge & Judul Terbaca Jelas
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.50),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.75),
                          ],
                          stops: const [0.0, 0.40, 1.0],
                        ),
                      ),
                    ),

                    // Overlay Expired Kuis jika sudah lewat batas waktu (persis Web)
                    if (quiz.isExpired && !quiz.requiresToken)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.35),
                            child: Image.asset(
                              'assets/widget/expiredQuiz.webp',
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.none,
                              opacity: const AlwaysStoppedAnimation(0.9),
                            ),
                          ),
                        ),
                      ),

                    // STEMPEL SELESAI (Top-Right) jika sudah lulus & dapat skor
                    if (isCompletedAndPassed)
                      Positioned(
                        top: 6,
                        right: 8,
                        child: Transform.rotate(
                          angle: -0.18,
                          child: Image.asset(
                            'assets/widget/quizBerhasilStempel.webp',
                            width: 68,
                            height: 68,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),

                    // BADGES DI ATAS COVER
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Baris Atas: Tipe Kuis & Token & Status
                          Row(
                            children: [
                              // Badge Tipe (Wayground / Biasa)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  quiz.isWayground
                                      ? '⚡ Wayground 360'
                                      : '⏱️ Kuis Biasa',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (quiz.requiresToken) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF581C87).withValues(
                                      alpha: 0.85,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFC084FC),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.lock_rounded,
                                        size: 11,
                                        color: Color(0xFFF3E8FF),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Token',
                                        style: TextStyle(
                                          color: Color(0xFFF3E8FF),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const Spacer(),
                              if (!isCompletedAndPassed)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: quiz.hasTaken
                                        ? const Color(0xFFF59E0B)
                                        : Colors.black.withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    quiz.hasTaken
                                        ? '💪 Belum Lulus'
                                        : 'Belum Dikerjakan',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          // Baris Bawah Cover: Jenjang, Indikator Foto Soal, & Tingkat Kesulitan
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (quiz.namaJenjang != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.6,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Jenjang ${quiz.namaJenjang}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  if (hasQuestionPhoto) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF047857),
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.photo_library_outlined,
                                            size: 11,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Foto Soal',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              // Tingkat Kesulitan (Pojok Kanan Bawah Cover persis Web)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: tingkatColor,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '● ${quiz.namaTingkat ?? 'Umum'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // =========================================================
              // 2. CARD BODY (Informasi Judul, Deskripsi, Tipe Soal & Metrik)
              // =========================================================
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.judul,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (quiz.deskripsi != null &&
                        quiz.deskripsi!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        quiz.deskripsi!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                    ],

                    // Ringkasan Jenis Soal di dalam Kuis (persis Web)
                    if (questionTypes.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: questionTypes.map((t) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFDBEAFE),
                              ),
                            ),
                            child: Text(
                              t,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Badges Metrik Kuis
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildBadge(
                          Icons.quiz_outlined,
                          '${quiz.questionsCount} Soal',
                        ),
                        _buildBadge(
                          Icons.bolt_rounded,
                          '${quiz.totalPoints} Poin',
                          color: const Color(0xFF2563EB),
                        ),
                        if (quiz.durasiTotalMenit != null)
                          _buildBadge(
                            Icons.schedule_rounded,
                            '${quiz.durasiTotalMenit} Menit',
                          ),
                        if (quiz.hasTaken)
                          _buildBadge(
                            Icons.emoji_events_rounded,
                            'Skor: ${quiz.userResult!.poinDidapat}/${quiz.userResult!.totalPoin}',
                            color: const Color(0xFFD97706),
                          ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // =========================================================
                    // 3. CARD ACTION FOOTER (Status Tersedia + Tombol Detail & Kerjakan)
                    // =========================================================
                    Container(
                      padding: const EdgeInsets.only(top: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Color(0xFFF1F5F9),
                            width: 1.2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Status Kuis (Kiri)
                          if (quiz.isExpired)
                            const Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Color(0xFFEF4444),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Kadaluarsa',
                                  style: TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            )
                          else
                            const Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Color(0xFF10B981),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Tersedia',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),

                          // Tombol Aksi (Kanan): Detail + Kerjakan
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () => _showQuizDetailSheet(quiz),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF334155),
                                  side: const BorderSide(
                                    color: Color(0xFFCBD5E1),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  minimumSize: const Size(0, 36),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Detail',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    colors: quiz.isExpired
                                        ? [
                                            const Color(0xFF94A3B8),
                                            const Color(0xFF64748B),
                                          ]
                                        : (quiz.hasTaken
                                            ? [
                                                const Color(0xFF0F172A),
                                                const Color(0xFF1E293B),
                                              ]
                                            : [
                                                const Color(0xFF2563EB),
                                                const Color(0xFF4F46E5),
                                              ]),
                                  ),
                                  boxShadow: [
                                    if (!quiz.isExpired)
                                      BoxShadow(
                                        color: (quiz.hasTaken
                                                ? const Color(0xFF0F172A)
                                                : const Color(0xFF2563EB))
                                            .withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: quiz.isExpired
                                      ? null
                                      : () => _showQuizDetailSheet(quiz),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    disabledForegroundColor: Colors.white70,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    minimumSize: const Size(0, 36),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        quiz.hasTaken
                                            ? 'Kerjakan Ulang'
                                            : 'Kerjakan',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        quiz.hasTaken
                                            ? Icons.replay_rounded
                                            : Icons.arrow_forward_rounded,
                                        size: 14,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, {Color? color}) {
    final effectiveColor = color ?? const Color(0xFF64748B);
    final bgColor = color != null ? color.withValues(alpha: 0.1) : const Color(0xFFF1F5F9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: effectiveColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
