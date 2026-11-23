import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/student_style_filter_bar.dart';
import 'create_quiz_page.dart';
import 'models/quiz_model.dart';
import 'services/quiz_service.dart';

class QuestionBankPage extends StatefulWidget {
  const QuestionBankPage({super.key});

  @override
  State<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> {
  static const List<String> _sumberFilters = [
    'Semua Sumber',
    '📚 Bank Soal Saja',
    '🎯 Terkait Kuis',
  ];

  static const List<String> _jenisFilters = [
    'Semua Tipe',
    'Pilihan Ganda',
    'Benar/Salah',
    'Isian Singkat',
    '🖼️ Bergambar',
  ];

  static const List<String> _tingkatFilters = [
    'Semua Tingkat',
    '🟢 Mudah',
    '🟡 Sedang',
    '🔴 Sulit',
  ];

  static const List<String> _jenjangFilters = [
    'Semua Jenjang',
    'SD',
    'SMP',
    'SMA',
  ];

  final TextEditingController _searchController = TextEditingController();
  final QuizService _service = QuizService();

  List<QuestionModel> _questions = [];
  List<MapelModel> _mapels = [];
  bool _isLoading = true;
  bool _isActionLoading = false;

  String _searchQuery = '';
  String _selectedSumber = 'Semua Sumber';
  String _selectedMapel = 'Semua Mapel';
  int? _selectedMapelId;
  String _selectedJenis = 'Semua Tipe';
  String _selectedTingkat = 'Semua Tingkat';
  String _selectedJenjang = 'Semua Jenjang';

  final Set<int> _selectedSoalIds = {};

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedSumber != 'Semua Sumber' ||
      _selectedMapel != 'Semua Mapel' ||
      _selectedJenis != 'Semua Tipe' ||
      _selectedTingkat != 'Semua Tingkat' ||
      _selectedJenjang != 'Semua Jenjang';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadQuestions(),
      _loadMapels(),
    ]);
  }

  Future<void> _loadMapels() async {
    try {
      final mapels = await _service.fetchMapels();
      if (mounted) {
        setState(() => _mapels = mapels);
      }
    } catch (_) {}
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    try {
      final list = await _service.fetchBankSoalList(
        sumber: 'all',
        limit: 250,
      );
      if (mounted) {
        setState(() {
          _questions = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedSumber = 'Semua Sumber';
      _selectedMapel = 'Semua Mapel';
      _selectedMapelId = null;
      _selectedJenis = 'Semua Tipe';
      _selectedTingkat = 'Semua Tingkat';
      _selectedJenjang = 'Semua Jenjang';
    });
  }

  List<QuestionModel> _getFilteredQuestions() {
    final qLower = _searchQuery.toLowerCase();

    return _questions.where((q) {
      // 1. Pencarian
      final matchQuery = qLower.isEmpty ||
          q.pertanyaan.toLowerCase().contains(qLower) ||
          (q.kodeSoal?.toLowerCase().contains(qLower) ?? false) ||
          (q.jawabanBenar?.toLowerCase().contains(qLower) ?? false) ||
          (q.mapelNama?.toLowerCase().contains(qLower) ?? false) ||
          q.pilihan.any((opt) => opt.teksPilihan.toLowerCase().contains(qLower));

      if (!matchQuery) return false;

      // 2. Filter Sumber
      if (_selectedSumber == '📚 Bank Soal Saja' && !q.isBank) {
        return false;
      }
      if (_selectedSumber == '🎯 Terkait Kuis' && q.isBank) {
        return false;
      }

      // 3. Filter Mapel
      if (_selectedMapelId != null && q.idMapel != null) {
        if (q.idMapel != _selectedMapelId) return false;
      } else if (_selectedMapel != 'Semua Mapel') {
        if (q.mapelNama?.trim().toLowerCase() != _selectedMapel.trim().toLowerCase()) {
          return false;
        }
      }

      // 4. Filter Tipe Soal
      switch (_selectedJenis) {
        case 'Pilihan Ganda':
          if (q.jenisSoal != JenisSoal.kuis) return false;
          break;
        case 'Benar/Salah':
          if (q.jenisSoal != JenisSoal.trueFalse) return false;
          break;
        case 'Isian Singkat':
          if (q.jenisSoal != JenisSoal.isianSingkat) return false;
          break;
        case '🖼️ Bergambar':
          if (!q.hasFoto) return false;
          break;
      }

      // 5. Filter Tingkat Kesulitan
      final tingkat = q.tingkatSoal.toLowerCase().trim();
      switch (_selectedTingkat) {
        case '🟢 Mudah':
          if (tingkat != 'mudah') return false;
          break;
        case '🟡 Sedang':
          if (tingkat != 'sedang' && tingkat.isNotEmpty) return false;
          break;
        case '🔴 Sulit':
          if (tingkat != 'sulit') return false;
          break;
      }

      // 6. Filter Jenjang
      if (_selectedJenjang != 'Semua Jenjang') {
        final jenjangStr = (q.jenjangNama ?? '').toLowerCase();
        if (_selectedJenjang == 'SD' && q.idJenjang != 1 && !jenjangStr.contains('sd')) {
          return false;
        }
        if (_selectedJenjang == 'SMP' && q.idJenjang != 2 && !jenjangStr.contains('smp')) {
          return false;
        }
        if (_selectedJenjang == 'SMA' && q.idJenjang != 3 && !jenjangStr.contains('sma')) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // ===========================================================================
  // AKSI BANK SOAL: SALIN KE BANK, ASSIGN KE KUIS, HAPUS
  // ===========================================================================

  Future<void> _copySingleToBank(int soalId) async {
    setState(() => _isActionLoading = true);
    try {
      final res = await _service.copySoalToBank([soalId]);
      final msg = res['message']?.toString() ?? 'Soal berhasil disalin ke Bank Soal.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ $msg'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
        _loadQuestions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyalin: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(0xFFE11D48),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _batchCopyToBank() async {
    if (_selectedSoalIds.isEmpty) return;
    setState(() => _isActionLoading = true);
    try {
      final ids = _selectedSoalIds.toList();
      final res = await _service.copySoalToBank(ids);
      final msg = res['message']?.toString() ?? 'Berhasil menyalin ${ids.length} soal ke Bank Soal.';
      if (mounted) {
        setState(() => _selectedSoalIds.clear());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ $msg'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
        _loadQuestions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyalin: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(0xFFE11D48),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _confirmDelete(QuestionModel q) async {
    if (q.idSoal == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Soal?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus butir soal ini dari sistem?\n\n"${q.displayTitle}"',
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isActionLoading = true);
    try {
      await _service.deleteSoal(q.idSoal!);
      if (mounted) {
        setState(() => _selectedSoalIds.remove(q.idSoal));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Soal berhasil dihapus.'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        _loadQuestions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(0xFFE11D48),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _showAssignQuizDialog(List<int> soalIds) async {
    if (soalIds.isEmpty) return;

    int? chosenQuizId;
    List<QuizModel> quizzes = [];
    bool isFetching = true;
    String? fetchError;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (isFetching) {
              _service.fetchQuizzes().then((res) {
                if (ctx.mounted) {
                  setModalState(() {
                    quizzes = res;
                    isFetching = false;
                  });
                }
              }).catchError((err) {
                if (ctx.mounted) {
                  setModalState(() {
                    fetchError = err.toString().replaceAll('Exception: ', '');
                    isFetching = false;
                  });
                }
              });
            }

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('📥', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Masukkan Soal ke Kuis',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Menyalin ${soalIds.length} butir soal ke kuis pilihan',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  if (isFetching)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else if (fetchError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Gagal memuat kuis: $fetchError',
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    )
                  else if (quizzes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Belum ada kuis yang dibuat. Buat kuis terlebih dahulu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      ),
                    )
                  else ...[
                    const Text(
                      'Pilih Kuis Tujuan:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 260),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: quizzes.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, idx) {
                          final quiz = quizzes[idx];
                          final isSelected = chosenQuizId == quiz.idQuiz;
                          return InkWell(
                            onTap: () {
                              setModalState(() => chosenQuizId = quiz.idQuiz);
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                                    color: isSelected ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          quiz.judul,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: isSelected ? const Color(0xFF065F46) : const Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${quiz.namaMapel ?? 'Umum'} • ${quiz.namaJenjang ?? 'Semua'} • ${quiz.questionsCount} Soal',
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
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: chosenQuizId == null
                            ? null
                            : () async {
                                final messenger = ScaffoldMessenger.of(context);
                                Navigator.pop(ctx);
                                setState(() => _isActionLoading = true);
                                try {
                                  final res = await _service.assignSoalToQuiz(chosenQuizId!, soalIds);
                                  final msg = res['message']?.toString() ?? 'Soal berhasil dimasukkan ke kuis.';
                                  if (!mounted) return;
                                  setState(() => _selectedSoalIds.clear());
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('✓ $msg'),
                                      backgroundColor: const Color(0xFF059669),
                                    ),
                                  );
                                  _loadQuestions();
                                } catch (e) {
                                  if (!mounted) return;
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Gagal memasukkan: ${e.toString().replaceAll('Exception: ', '')}'),
                                      backgroundColor: const Color(0xFFE11D48),
                                    ),
                                  );
                                } finally {
                                  if (mounted) setState(() => _isActionLoading = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Masukkan ke Kuis Terpilih',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(ctx),
              icon: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // BUILD METHOD & UI
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredQuestions();

    final List<String> mapelOptions = [
      'Semua Mapel',
      ..._mapels.map((m) => m.namaMapel),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Bank Soal',
              onNotificationTap: () {},
            ),

            if (_isActionLoading)
              const LinearProgressIndicator(
                color: AppColors.primary,
                backgroundColor: Color(0xFFE2E8F0),
                minHeight: 3,
              ),

            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadQuestions,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [
                    // Heading & Header Info persis web Arrava
                    _buildPageHeading(),

                    const SizedBox(height: 16),

                    // Filter Card Bergaya Arrava
                    _buildFilterSection(mapelOptions, filtered.length),

                    const SizedBox(height: 16),

                    // Status Bar & Reset
                    _buildFilterStatusRow(filtered.length),

                    const SizedBox(height: 14),

                    // Content List
                    if (_isLoading && _questions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      )
                    else if (filtered.isEmpty)
                      _buildEmptyState()
                    else
                      ...filtered.map((q) => _buildQuestionCard(q)),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Bar untuk aksi batch (muncul saat ada checkbox dicentang)
            if (_selectedSoalIds.isNotEmpty) _buildBatchActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFB2E7FC)),
              ),
              child: const Text(
                '📚 Repositori Soal & Dungeon',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF007FBE),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateQuizPage()),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Buat Kuis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007FBE),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Bank Soal',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Kelola soal mandiri (Bank Soal) dan soal pada kuis. Anda dapat menyalin soal bank ke kuis atau menyalin soal kuis ke bank soal kapan saja.',
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(List<String> mapelOptions, int currentCount) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Field
          StudentStyleSearchField(
            controller: _searchController,
            hintText: 'Cari pertanyaan, kode soal, mapel, atau kunci...',
            hasQuery: _searchQuery.isNotEmpty,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
          const SizedBox(height: 12),

          // Row 1: Sumber Soal
          StudentStyleFilterChipBar(
            label: 'Sumber',
            options: _sumberFilters,
            selectedOption: _selectedSumber,
            onSelected: (val) => setState(() => _selectedSumber = val),
          ),
          const SizedBox(height: 10),

          // Row 2: Mata Pelajaran (jika ada)
          if (mapelOptions.length > 1) ...[
            StudentStyleFilterChipBar(
              label: 'Mata Pelajaran',
              options: mapelOptions,
              selectedOption: _selectedMapel,
              onSelected: (val) {
                setState(() {
                  _selectedMapel = val;
                  if (val == 'Semua Mapel') {
                    _selectedMapelId = null;
                  } else {
                    final found = _mapels.where((m) => m.namaMapel == val).firstOrNull;
                    _selectedMapelId = found?.idMapel;
                  }
                });
              },
            ),
            const SizedBox(height: 10),
          ],

          // Row 3: Tipe Soal
          StudentStyleFilterChipBar(
            label: 'Tipe Soal',
            options: _jenisFilters,
            selectedOption: _selectedJenis,
            onSelected: (val) => setState(() => _selectedJenis = val),
          ),
          const SizedBox(height: 10),

          // Row 4: Tingkat Kesulitan
          StudentStyleFilterChipBar(
            label: 'Tingkat Kesulitan',
            options: _tingkatFilters,
            selectedOption: _selectedTingkat,
            onSelected: (val) => setState(() => _selectedTingkat = val),
          ),
          const SizedBox(height: 10),

          // Row 5: Jenjang
          StudentStyleFilterChipBar(
            label: 'Jenjang',
            options: _jenjangFilters,
            selectedOption: _selectedJenjang,
            onSelected: (val) => setState(() => _selectedJenjang = val),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterStatusRow(int currentCount) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Menampilkan $currentCount dari ${_questions.length} soal',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF475569),
            ),
          ),
        ),
        const Spacer(),
        if (_hasActiveFilters)
          TextButton.icon(
            onPressed: _resetFilters,
            icon: const Icon(Icons.refresh_rounded, size: 14),
            label: const Text(
              'Reset Filter',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF007FBE),
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 30),
            ),
          ),
      ],
    );
  }

  Widget _buildQuestionCard(QuestionModel q) {
    final isSelected = q.idSoal != null && _selectedSoalIds.contains(q.idSoal);
    final resolvedFoto = ApiConstants.resolveMediaUrl(q.fotoUrl ?? q.fotoSoal);

    // Tipe Badge
    final String jenisLabel;
    final Color jenisBg;
    final Color jenisText;
    final Color jenisBorder;

    if (q.jenisSoal == JenisSoal.trueFalse) {
      jenisLabel = 'Benar/Salah';
      jenisBg = const Color(0xFFFFFBEB);
      jenisText = const Color(0xFFB45309);
      jenisBorder = const Color(0xFFFDE68A);
    } else if (q.jenisSoal == JenisSoal.isianSingkat) {
      jenisLabel = 'Isian Singkat';
      jenisBg = const Color(0xFFFAF5FF);
      jenisText = const Color(0xFF7E22CE);
      jenisBorder = const Color(0xFFE9D5FF);
    } else {
      jenisLabel = 'Pilihan Ganda';
      jenisBg = const Color(0xFFF0F9FF);
      jenisText = const Color(0xFF007FBE);
      jenisBorder = const Color(0xFFB2E7FC);
    }

    // Tingkat Badge
    final tingkatSlug = q.tingkatSoal.toLowerCase().trim();
    final String tingkatLabel;
    if (tingkatSlug == 'mudah') {
      tingkatLabel = '🟢 Mudah';
    } else if (tingkatSlug == 'sulit') {
      tingkatLabel = '🔴 Sulit';
    } else {
      tingkatLabel = '🟡 Sedang';
    }

    final quizTitle = q.sumberLabel ?? (q.isBank ? '📚 Bank Soal' : '🎯 Terkait Kuis');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? const Color(0xFF007FBE) : const Color(0xFFE6F1FC),
          width: isSelected ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Header: Checkbox, Badge Sumber, Tipe, Tingkat, Kode
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (q.idSoal != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: isSelected,
                      activeColor: const Color(0xFF007FBE),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedSoalIds.add(q.idSoal!);
                          } else {
                            _selectedSoalIds.remove(q.idSoal!);
                          }
                        });
                      },
                    ),
                  ),
                ),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Badge Sumber: Bank Soal (Indigo) vs Kuis (Sky)
                    if (q.isBank)
                      _buildChipTag('📚 Bank Soal', const Color(0xFFEEF2FF), const Color(0xFF4338CA), const Color(0xFFC7D2FE))
                    else
                      _buildChipTag(quizTitle, const Color(0xFFF0F9FF), const Color(0xFF007FBE), const Color(0xFFB2E7FC)),

                    // Badge Tipe Soal
                    _buildChipTag(jenisLabel, jenisBg, jenisText, jenisBorder),

                    // Badge Tingkat Kesulitan
                    _buildChipTag(tingkatLabel, const Color(0xFFF8FAFC), const Color(0xFF334155), const Color(0xFFE2E8F0)),

                    // Badge Foto
                    if (q.hasFoto)
                      _buildChipTag('🖼️ Foto', const Color(0xFFECFDF5), const Color(0xFF047857), const Color(0xFFA7F3D0)),
                  ],
                ),
              ),

              if (q.kodeSoal != null && q.kodeSoal!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    q.kodeSoal!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Sub Meta: Mapel, Jenjang, Skor, Timer
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '📖 ${q.mapelNama ?? 'Semua Mapel'}',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Text('•', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
              Text(
                '🎓 ${q.jenjangNama ?? 'Umum'}',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const Text('•', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
              Text(
                '${q.poin} Poin',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const Text('•', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
              Text(
                '${q.durasiDetik}s',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Teks Pertanyaan & Gambar Thumbnail
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  q.pertanyaan.trim().isNotEmpty ? q.pertanyaan : q.displayTitle,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    fontStyle: q.pertanyaan.trim().isEmpty ? FontStyle.italic : FontStyle.normal,
                    fontWeight: FontWeight.w700,
                    color: q.pertanyaan.trim().isNotEmpty ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                  ),
                ),
              ),
              if (resolvedFoto != null) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _showImagePreview(resolvedFoto),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 65,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        border: Border.all(color: const Color(0xFFDCEFFF)),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            resolvedFoto,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.zoom_in, size: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Pilihan Jawaban
          if (q.pilihan.isNotEmpty) ...[
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: q.pilihan.map((opt) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: opt.isCorrect ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: opt.isCorrect ? const Color(0xFFA7F3D0) : const Color(0xFFF1F5F9),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: opt.isCorrect ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            opt.label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: opt.isCorrect ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            opt.teksPilihan,
                            style: TextStyle(
                              fontSize: 12,
                              color: opt.isCorrect ? const Color(0xFF065F46) : const Color(0xFF334155),
                              fontWeight: opt.isCorrect ? FontWeight.w800 : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (opt.isCorrect)
                          const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF059669)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          // Footer: Kunci Jawaban & Tombol Aksi
          Row(
            children: [
              Expanded(
                child: Text(
                  'Kunci: ${q.jawabanBenar ?? '-'} | Oleh: ${q.penulisNama ?? 'Admin'}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),

              // Aksi: Salin ke Bank (jika soal kuis)
              if (!q.isBank && q.idSoal != null) ...[
                OutlinedButton.icon(
                  onPressed: () => _copySingleToBank(q.idSoal!),
                  icon: const Text('💾', style: TextStyle(fontSize: 11)),
                  label: const Text('Salin ke Bank'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF047857),
                    backgroundColor: const Color(0xFFECFDF5),
                    side: const BorderSide(color: Color(0xFFA7F3D0)),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 30),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 6),
              ],

              // Aksi: Masukkan ke Kuis
              if (q.idSoal != null) ...[
                ElevatedButton.icon(
                  onPressed: () => _showAssignQuizDialog([q.idSoal!]),
                  icon: const Text('📥', style: TextStyle(fontSize: 11)),
                  label: const Text('Ke Kuis'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF0F9FF),
                    foregroundColor: const Color(0xFF007FBE),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFB2E7FC)),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 30),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 6),
              ],

              // Aksi: Hapus
              if (q.idSoal != null)
                IconButton(
                  onPressed: () => _confirmDelete(q),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFE11D48)),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF1F2),
                    minimumSize: const Size(30, 30),
                    padding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChipTag(String label, Color bg, Color text, Color border) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: text,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F9FF),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('📝', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _hasActiveFilters
                ? 'Tidak ada soal yang cocok dengan filter'
                : 'Belum Ada Soal di Bank Soal',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _hasActiveFilters
                ? 'Silakan ubah filter atau kata kunci pencarian Anda untuk melihat pertanyaan lainnya.'
                : 'Tambahkan butir soal baru atau salin dari kuis yang sudah dibuat.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
              label: const Text('Reset Filter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF007FBE),
                side: const BorderSide(color: Color(0xFFB2E7FC)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBatchActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF007FBE)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_selectedSoalIds.length} soal dipilih',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const Text(
                  'Pilih aksi batch',
                  style: TextStyle(color: Color(0xFFE0F2FE), fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _batchCopyToBank,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            child: const Text('💾 Salin ke Bank'),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            onPressed: () => _showAssignQuizDialog(_selectedSoalIds.toList()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF007FBE),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            child: const Text('➕ Ke Kuis'),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () => setState(() => _selectedSoalIds.clear()),
            icon: const Icon(Icons.close, color: Colors.white, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }
}
