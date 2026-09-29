import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_header.dart';
import 'manage_quiz_page.dart';
import 'question_bank_page.dart';

class QuizMenuPage extends StatelessWidget {
  const QuizMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppHeader(
            title: 'Kuis & Evaluasi',
            onNotificationTap: () {},
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kuis & Evaluasi',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Kelola quiz dan bank soal pembelajaran',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildMenuCard(
                    context: context,
                    icon: Icons.quiz_outlined,
                    title: 'Kelola Quiz',
                    description:
                        'Buat, kelola, dan pantau quiz untuk siswa.',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageQuizPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  _buildMenuCard(
                    context: context,
                    icon: Icons.library_books_outlined,
                    title: 'Bank Soal',
                    description:
                        'Kelola kumpulan soal yang dapat digunakan dalam quiz.',
                    color: AppColors.success,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QuestionBankPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 23,
              ),
            ],
          ),
        ),
      ),
    );
  }
}