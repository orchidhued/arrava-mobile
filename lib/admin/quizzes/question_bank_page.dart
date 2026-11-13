import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/student_style_filter_bar.dart';
import 'models/quiz_model.dart';
import 'services/quiz_service.dart';

class QuestionBankPage extends StatefulWidget {
  const QuestionBankPage({super.key});

  @override
  State<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> {
  static const List<String> _filters = [
    'Semua',
    'Pilihan Ganda',
    'Benar/Salah',
    'Isian',
    'Bergambar',
  ];

  final TextEditingController _searchController = TextEditingController();
  final QuizService _service = QuizService();

  List<QuestionModel> _questions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty || _selectedFilter != 'Semua';

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedFilter = 'Semua';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final list = await _service.fetchQuestionBankModels();
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

  List<QuestionModel> _getFilteredQuestions() {
    final qLower = _searchQuery.toLowerCase();
    return _questions.where((q) {
      final matchQuery =
          qLower.isEmpty ||
          q.pertanyaan.toLowerCase().contains(qLower) ||
          q.pilihan.any(
            (opt) => opt.teksPilihan.toLowerCase().contains(qLower),
          );

      final bool matchFilter;
      switch (_selectedFilter) {
        case 'Pilihan Ganda':
          matchFilter = q.jenisSoal == JenisSoal.kuis;
          break;
        case 'Benar/Salah':
          matchFilter = q.jenisSoal == JenisSoal.trueFalse;
          break;
        case 'Isian':
          matchFilter = q.jenisSoal == JenisSoal.isianSingkat;
          break;
        case 'Bergambar':
          matchFilter = (q.fotoSoal?.trim().isNotEmpty ?? false);
          break;
        default:
          matchFilter = true;
      }

      return matchQuery && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredQuestions();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Bank Soal', onNotificationTap: () {}),

            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadQuestions,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bank Soal',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Total ${_questions.length} butir soal di database',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _buildSearchField(),

                    const SizedBox(height: 10),

                    StudentStyleFilterChipBar(
                      options: _filters,
                      selectedOption: _selectedFilter,
                      onSelected: (val) => setState(() => _selectedFilter = val),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Text(
                          'Menampilkan ${filtered.length} soal',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: kStudentFilterMuted,
                          ),
                        ),
                        const Spacer(),
                        if (_hasActiveFilters)
                          TextButton.icon(
                            onPressed: _resetFilters,
                            icon: const Icon(Icons.refresh_rounded, size: 14),
                            label: const Text(
                              'Reset Filter',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: kStudentFilterBlue,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (_isLoading && _questions.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      )
                    else if (filtered.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.quiz_outlined, size: 36, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            Text(
                              _hasActiveFilters
                                  ? 'Tidak ada soal yang cocok dengan filter atau kata kunci saat ini.'
                                  : 'Belum ada butir soal di database',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            ),
                            if (_hasActiveFilters) ...[
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _resetFilters,
                                icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                                label: const Text('Reset Filter'),
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      ...filtered.map(
                        (q) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildQuestionCard(q),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return StudentStyleSearchField(
      controller: _searchController,
      hintText: 'Cari pertanyaan atau pilihan jawaban...',
      hasQuery: _searchQuery.isNotEmpty,
      onChanged: (val) => setState(() => _searchQuery = val.trim()),
      onClear: () {
        _searchController.clear();
        setState(() => _searchQuery = '');
      },
    );
  }

  Widget _buildQuestionCard(QuestionModel q) {
    final typeName = q.jenisSoal == JenisSoal.trueFalse
        ? 'Benar/Salah'
        : (q.jenisSoal == JenisSoal.isianSingkat ? 'Isian' : 'Pilihan Ganda');
    final resolvedFoto = ApiConstants.resolveMediaUrl(q.fotoSoal);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTag(
                typeName,
                AppColors.primaryLight,
                AppColors.primaryDark,
              ),

              const SizedBox(width: 6),

              _buildTag(
                '${q.poin} Poin',
                const Color(0xFFE5EAF3),
                AppColors.textSecondary,
              ),

              const Spacer(),

              _buildTag(
                '${q.durasiDetik}s',
                const Color(0xFFD9FBEA),
                AppColors.success,
              ),
            ],
          ),

          const SizedBox(height: 11),

          if (resolvedFoto != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 120,
                width: double.infinity,
                color: const Color(0xFFF1F5F9),
                child: Image.network(
                  resolvedFoto,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          Text(
            q.pertanyaan.trim().isNotEmpty ? q.pertanyaan : q.displayTitle,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              fontStyle: q.pertanyaan.trim().isEmpty ? FontStyle.italic : FontStyle.normal,
              fontWeight: FontWeight.w600,
              color: q.pertanyaan.trim().isNotEmpty ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),

          if (q.pilihan.isNotEmpty) ...[
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: q.pilihan.map((opt) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: opt.isCorrect
                              ? const Color(0xFF10B981).withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          opt.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: opt.isCorrect ? const Color(0xFF059669) : Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          opt.teksPilihan,
                          style: TextStyle(
                            fontSize: 12,
                            color: opt.isCorrect ? const Color(0xFF059669) : AppColors.textPrimary,
                            fontWeight: opt.isCorrect ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
      ),
    );
  }
}
