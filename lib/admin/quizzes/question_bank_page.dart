import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_header.dart';

class QuestionBankPage extends StatelessWidget {
  const QuestionBankPage({super.key});

  @override
  Widget build(BuildContext context) {
    final questions = [
      _QuestionData(
        question:
            'Manakah yang merupakan struktur dasar dari sebuah algoritma?',
        category: 'Pemrograman',
        type: 'Pilihan Ganda',
        difficulty: 'Mudah',
      ),
      _QuestionData(
        question: 'Apa fungsi utama dari Design System dalam pengembangan UI?',
        category: 'Desain UI/UX',
        type: 'Pilihan Ganda',
        difficulty: 'Sedang',
      ),
      _QuestionData(
        question: 'Manakah metode yang digunakan untuk membersihkan data menggunakan Pandas?',
        category: 'Data Science',
        type: 'Pilihan Ganda',
        difficulty: 'Sedang',
      ),
      _QuestionData(
        question: 'Apa kegunaan REST API dalam aplikasi web modern?',
        category: 'Pemrograman',
        type: 'Pilihan Ganda',
        difficulty: 'Sulit',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Bank Soal', onNotificationTap: () {}),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bank Soal',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Kumpulan soal untuk kebutuhan quiz',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Tambah soal
                        },
                        icon: const Icon(Icons.add, size: 17),
                        label: const Text(
                          'Soal',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(90, 42),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _buildSearch(),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Daftar Soal',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${questions.length} soal',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  ...questions.map(
                    (question) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildQuestionCard(question),
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

  Widget _buildSearch() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Cari soal...',
        hintStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(_QuestionData question) {
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
                question.category,
                AppColors.primaryLight,
                AppColors.primaryDark,
              ),

              const SizedBox(width: 6),

              _buildTag(
                question.type,
                const Color(0xFFE5EAF3),
                AppColors.textSecondary,
              ),

              const Spacer(),

              _buildDifficulty(question.difficulty),
            ],
          ),

          const SizedBox(height: 11),

          Text(
            question.question,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Edit soal
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),

              IconButton(
                onPressed: () {
                  // TODO: Delete soal
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
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
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
      ),
    );
  }

  Widget _buildDifficulty(String difficulty) {
    Color background;
    Color foreground;

    switch (difficulty) {
      case 'Mudah':
        background = const Color(0xFFD9FBEA);
        foreground = AppColors.success;
        break;

      case 'Sulit':
        background = const Color(0xFFFFD9D5);
        foreground = AppColors.error;
        break;

      default:
        background = const Color(0xFFFFF0C2);
        foreground = const Color(0xFF9A6700);
    }

    return _buildTag(difficulty, background, foreground);
  }
}

class _QuestionData {
  final String question;
  final String category;
  final String type;
  final String difficulty;

  const _QuestionData({
    required this.question,
    required this.category,
    required this.type,
    required this.difficulty,
  });
}
