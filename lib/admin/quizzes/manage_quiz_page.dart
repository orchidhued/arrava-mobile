import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_header.dart';
import 'create_quiz_page.dart';

class ManageQuizPage extends StatelessWidget {
  const ManageQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    final quizzes = [
      _QuizData(
        title: 'Evaluasi Algoritma & Logika',
        module: 'Modul 1: Pengantar Algoritma',
        questions: 20,
        participants: 128,
        status: 'Aktif',
      ),
      _QuizData(
        title: 'UI/UX Design System',
        module: 'Modul 2: UI/UX Design System Mastery',
        questions: 25,
        participants: 96,
        status: 'Aktif',
      ),
      _QuizData(
        title: 'Fullstack React & Node.js',
        module: 'Modul 3: Fullstack React & Node.js',
        questions: 30,
        participants: 84,
        status: 'Aktif',
      ),
      _QuizData(
        title: 'Data Analytics dengan Python',
        module: 'Modul 4: Data Analytics with Python & SQL',
        questions: 25,
        participants: 0,
        status: 'Draft',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Kelola Quiz',
              onNotificationTap: () {},
            ),

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
                              'Kelola Quiz',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Buat dan kelola evaluasi siswa',
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateQuizPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 17),
                        label: const Text(
                          'Quiz',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(92, 42),
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

                  ...quizzes.map(
                    (quiz) => Padding(
                      padding: const EdgeInsets.only(bottom: 11),
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

  Widget _buildSearch() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Cari quiz...',
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

  Widget _buildQuizCard(_QuizData quiz) {
    final bool active = quiz.status == 'Aktif';

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
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.quiz_outlined,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  quiz.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(width: 7),

              _buildStatus(quiz.status),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            quiz.module,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              _buildInfo(Icons.help_outline, '${quiz.questions} Soal'),

              const SizedBox(width: 16),

              _buildInfo(Icons.people_outline, '${quiz.participants} Peserta'),

              const Spacer(),

              IconButton(
                onPressed: () {
                  // TODO: Edit quiz
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),

              IconButton(
                onPressed: () {
                  // TODO: Delete quiz
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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

  Widget _buildInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatus(String status) {
    final bool active = status == 'Aktif';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF63E6B2) : const Color(0xFFE5EAF3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: active ? const Color(0xFF006B4A) : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _QuizData {
  final String title;
  final String module;
  final int questions;
  final int participants;
  final String status;

  const _QuizData({
    required this.title,
    required this.module,
    required this.questions,
    required this.participants,
    required this.status,
  });
}
