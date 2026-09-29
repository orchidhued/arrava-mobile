import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class QuizNavigation extends StatelessWidget {
  final int totalQuestions;
  final int currentQuestion;
  final ValueChanged<int> onSelectQuestion;
  final VoidCallback onAddQuestion;

  const QuizNavigation({
    super.key,
    required this.totalQuestions,
    required this.currentQuestion,
    required this.onSelectQuestion,
    required this.onAddQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuestionNavigation(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: onAddQuestion,
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text(
                    'Tambahkan Soal Baru',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionNavigation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 7),
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'NAVIGASI SOAL',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Color(0xFF64748B),
                ),
              ),
              const Spacer(),
              Text(
                'Total: $totalQuestions Soal',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: totalQuestions + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == totalQuestions) {
                  return _buildNewQuestionThumbnail();
                }
                return _buildQuestionThumbnail(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionThumbnail(int index) {
    final bool selected = currentQuestion == index;

    return InkWell(
      onTap: () => onSelectQuestion(index),
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: 68,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. Kuis',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                _miniColor(const Color(0xFFE5254A)),
                _miniColor(const Color(0xFF1368CE)),
                _miniColor(const Color(0xFFD89E00)),
                _miniColor(const Color(0xFF26890C)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniColor(Color color) {
    return Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildNewQuestionThumbnail() {
    return InkWell(
      onTap: onAddQuestion,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: 68,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 19, color: Color(0xFF94A3B8)),
            SizedBox(height: 1),
            Text(
              'Baru',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
