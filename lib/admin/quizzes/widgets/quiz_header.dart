import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class QuizHeader extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback? onBackPressed;

  const QuizHeader({
    super.key,
    required this.onSave,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              onPressed: onBackPressed ?? () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: Color(0xFF475569)),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buat Kuis Baru',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: const [
                    Icon(
                      Icons.check_circle,
                      size: 13,
                      color: Color(0xFF059669),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Draf tersimpan',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 88,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.check, size: 15),
              label: const Text(
                'Simpan',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizTitleSection extends StatelessWidget {
  final TextEditingController titleController;
  final int currentQuestion;
  final int totalQuestions;
  final int timeLimit;
  final int points;

  const QuizTitleSection({
    super.key,
    required this.titleController,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.timeLimit,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Masukkan judul kuis...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(
                Icons.edit_note,
                size: 20,
                color: Color(0xFF94A3B8),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: Color(0xFF2563EB)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Text(
                  'Soal ${currentQuestion + 1} / $totalQuestions',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),
              const SizedBox(width: 7),
              const Text('•', style: TextStyle(color: Color(0xFF94A3B8))),
              const SizedBox(width: 7),
              const Icon(
                Icons.timer_outlined,
                size: 15,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 3),
              Text(
                '${timeLimit}s',
                style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
              ),
              const Spacer(),
              const Icon(
                Icons.military_tech,
                size: 16,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 3),
              Text(
                '$points Poin',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
