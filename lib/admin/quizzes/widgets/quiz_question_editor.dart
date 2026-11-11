import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/quiz_model.dart';
import '../models/quiz_question.dart';
import 'quiz_answer_item.dart';

class QuizQuestionEditor extends StatelessWidget {
  final QuizQuestion question;
  final ValueChanged<int> onSelectCorrectAnswer;
  final ValueChanged<JenisSoal> onChangedJenisSoal;
  final VoidCallback onPickPhoto;
  final VoidCallback onRemovePhoto;

  const QuizQuestionEditor({
    super.key,
    required this.question,
    required this.onSelectCorrectAnswer,
    required this.onChangedJenisSoal,
    required this.onPickPhoto,
    required this.onRemovePhoto,
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
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJenisSoalSelector(),
          const SizedBox(height: 12),
          _buildQuestionInput(),
          const SizedBox(height: 12),
          _buildMediaUpload(context),
          const SizedBox(height: 14),
          _buildAnswerSection(),
        ],
      ),
    );
  }

  Widget _buildJenisSoalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.tune_rounded, size: 14, color: Color(0xFFDBEAFE)),
            const SizedBox(width: 5),
            const Text(
              'TIPE SOAL INI',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Color(0xFFBFDBFE),
              ),
            ),
            const Spacer(),
            Text(
              question.jenisSoal == JenisSoal.kuis
                  ? 'Pilihan Ganda (4 Opsi)'
                  : (question.jenisSoal == JenisSoal.trueFalse
                      ? 'Benar atau Salah'
                      : 'Isian Singkat'),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFF93C5FD),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFF1E40AF).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              _buildTypeTab(
                label: 'Pilgan',
                icon: Icons.quiz_outlined,
                selected: question.jenisSoal == JenisSoal.kuis,
                onTap: () => onChangedJenisSoal(JenisSoal.kuis),
              ),
              _buildTypeTab(
                label: 'Benar / Salah',
                icon: Icons.thumbs_up_down_outlined,
                selected: question.jenisSoal == JenisSoal.trueFalse,
                onTap: () => onChangedJenisSoal(JenisSoal.trueFalse),
              ),
              _buildTypeTab(
                label: 'Isian Singkat',
                icon: Icons.edit_note_rounded,
                selected: question.jenisSoal == JenisSoal.isianSingkat,
                onTap: () => onChangedJenisSoal(JenisSoal.isianSingkat),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeTab({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: selected ? const Color(0xFF1D4ED8) : const Color(0xFFDBEAFE),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE),
                  ),
                ),
              ),
            ],
          ),
        ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
    final bool hasMemoryPhoto = question.fotoBytes != null;
    final bool hasExistingPhoto = question.existingFotoUrl != null &&
        question.existingFotoUrl!.isNotEmpty &&
        !question.removeFoto;

    if (hasMemoryPhoto || hasExistingPhoto) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Container(
              height: 170,
              width: double.infinity,
              color: const Color(0xFFF1F5F9),
              child: hasMemoryPhoto
                  ? Image.memory(
                      question.fotoBytes!,
                      fit: BoxFit.contain,
                    )
                  : Image.network(
                      ApiConstants.resolveMediaUrl(question.existingFotoUrl) ?? '',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Center(
                        child: Icon(Icons.broken_image, color: Color(0xFF94A3B8), size: 40),
                      ),
                    ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
                onTap: onRemovePhoto,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBE123C),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Hapus Gambar',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  question.fotoName ?? 'Gambar Soal Terpasang',
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onPickPhoto,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: Colors.white,
                size: 21,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Unggah Gambar Soal (Opsional)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'PNG, JPG, WebP • Maks 2MB',
              style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerSection() {
    switch (question.jenisSoal) {
      case JenisSoal.trueFalse:
        return _buildTrueFalseAnswers();
      case JenisSoal.isianSingkat:
        return _buildIsianSingkatAnswer();
      case JenisSoal.kuis:
        return _buildMultipleChoiceAnswers();
    }
  }

  Widget _buildMultipleChoiceAnswers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Pilihan Jawaban',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Spacer(),
            Text(
              'Wajib min. 2 opsi & 1 benar',
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
    );
  }

  Widget _buildTrueFalseAnswers() {
    final isTrue = question.correctAnswer == 0;
    final isFalse = question.correctAnswer == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Kunci Jawaban Benar / Salah',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Spacer(),
            Text(
              'Pilih opsi yang benar',
              style: TextStyle(fontSize: 9, color: Color(0xFFBFDBFE)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Card Benar (Opsi A)
            Expanded(
              child: InkWell(
                onTap: () => onSelectCorrectAnswer(0),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isTrue ? const Color(0xFF10B981) : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isTrue
                            ? const Color(0xFF10B981).withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isTrue ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                        ),
                        child: Icon(
                          Icons.check,
                          color: isTrue ? Colors.white : const Color(0xFF64748B),
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'A. BENAR',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isTrue ? 'Kunci Jawaban' : 'Ketuk untuk memilih',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: isTrue ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Card Salah (Opsi B)
            Expanded(
              child: InkWell(
                onTap: () => onSelectCorrectAnswer(1),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isFalse ? const Color(0xFFEF4444) : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isFalse
                            ? const Color(0xFFEF4444).withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFalse ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0),
                        ),
                        child: Icon(
                          Icons.close,
                          color: isFalse ? Colors.white : const Color(0xFF64748B),
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'B. SALAH',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isFalse ? 'Kunci Jawaban' : 'Ketuk untuk memilih',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: isFalse ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIsianSingkatAnswer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF34D399), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.key_rounded, size: 16, color: Color(0xFF059669)),
              SizedBox(width: 6),
              Text(
                'Kunci Jawaban Isian Singkat',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF065F46),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Ketikkan jawaban yang benar. Sistem mencocokkan jawaban siswa tanpa membedakan huruf besar/kecil.',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF475569),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: question.shortAnswerController,
            decoration: InputDecoration(
              hintText: 'Ketik kunci jawaban yang benar di sini...',
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF0FDF4),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFA7F3D0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFA7F3D0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5),
              ),
            ),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF065F46),
            ),
          ),
        ],
      ),
    );
  }
}
