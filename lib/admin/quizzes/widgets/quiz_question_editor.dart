import 'package:flutter/material.dart';

import '../models/quiz_question.dart';
import 'quiz_answer_item.dart';

class QuizQuestionEditor extends StatelessWidget {
  final QuizQuestion question;
  final ValueChanged<int> onSelectCorrectAnswer;

  const QuizQuestionEditor({
    super.key,
    required this.question,
    required this.onSelectCorrectAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E40AF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: 14,
                      color: Color(0xFFDBEAFE),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Pilihan Ganda',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDBEAFE),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Flexible(
                child: Text(
                  'Pilih jawaban benar',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 9, color: Color(0xFFBFDBFE)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildQuestionInput(),
          const SizedBox(height: 12),
          _buildMediaUpload(context),
          const SizedBox(height: 14),
          const Row(
            children: [
              Text(
                'Pilihan Jawaban',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              Text(
                'Wajib min. 2 opsi',
                style: TextStyle(fontSize: 9, color: Color(0xFFBFDBFE)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (int index = 0; index < question.answers.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: QuizAnswerItem(
                index: index,
                controller: question.answers[index],
                isCorrect: question.correctAnswer == index,
                onSelectCorrect: () => onSelectCorrectAnswer(index),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionInput() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: question.questionController,
        maxLines: 4,
        minLines: 3,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Ketikkan pertanyaan Anda di sini...',
          hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildMediaUpload(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fitur upload media akan dihubungkan nanti.'),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.45)),
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: Colors.white,
                size: 23,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Unggah file gambar/media',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'PNG, JPG, atau WebP • Maks 5MB',
              style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
