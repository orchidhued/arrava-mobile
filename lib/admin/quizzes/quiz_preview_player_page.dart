import 'dart:async';
import 'package:flutter/material.dart';
import 'models/quiz_model.dart';

class QuizPreviewPlayerPage extends StatefulWidget {
  final int? quizId;
  final String title;
  final String jenjang;
  final String difficulty;
  final String mode;
  final int totalQuestions;
  final int totalPoints;
  final int timeLimitPerQuestion;
  final List<QuestionModel>? initialQuestions;

  const QuizPreviewPlayerPage({
    super.key,
    this.quizId,
    required this.title,
    required this.jenjang,
    required this.difficulty,
    this.mode = 'Wayground',
    this.totalQuestions = 5,
    this.totalPoints = 100,
    this.timeLimitPerQuestion = 20,
    this.initialQuestions,
  });

  @override
  State<QuizPreviewPlayerPage> createState() => _QuizPreviewPlayerPageState();
}

class _QuizPreviewPlayerPageState extends State<QuizPreviewPlayerPage> {
  int _currentIndex = 0;
  int? _selectedAnswerIndex;
  bool _isAnswerSubmitted = false;
  int _score = 0;
  int _correctCount = 0;
  late int _remainingSeconds;
  Timer? _timer;

  List<_SampleQuestion> _activeQuestions = [];
  List<_SampleQuestion> get _questions =>
      _activeQuestions.isNotEmpty ? _activeQuestions : _sampleQuestions;

  // Mock sample questions in Kahoot style
  final List<_SampleQuestion> _sampleQuestions = [
    _SampleQuestion(
      question:
          'Manakah dari berikut ini yang merupakan karakteristik utama dari algoritma Greedy?',
      answers: [
        'Memilih langkah terbaik pada setiap langkah lokal',
        'Mengeksplorasi seluruh kemungkinan cabang pohon',
        'Menggunakan tabel lookup dinamis secara rekursif',
        'Mengacak urutan input secara acak berulang kali',
      ],
      correctAnswerIndex: 0,
      points: 20,
    ),
    _SampleQuestion(
      question:
          'Struktur data mana yang paling efisien untuk operasi First-In First-Out (FIFO)?',
      answers: [
        'Stack (Tumpukan)',
        'Queue (Antrean)',
        'Binary Search Tree',
        'Hash Table Terbuka',
      ],
      correctAnswerIndex: 1,
      points: 20,
    ),
    _SampleQuestion(
      question:
          'Dalam pemrograman berorientasi objek, apa arti dari konsep Polymorphism?',
      answers: [
        'Menyembunyikan detail implementasi data pribadi',
        'Mewariskan properti dari class induk ke anak',
        'Kemampuan objek memiliki banyak bentuk implementasi',
        'Menggabungkan baris kode menjadi satu modul tunggal',
      ],
      correctAnswerIndex: 2,
      points: 20,
    ),
    _SampleQuestion(
      question:
          'Manakah yang BUKAN merupakan prinsip dasar dalam UI/UX Design System?',
      answers: [
        'Konsistensi Visual dan Komponen',
        'Aksesibilitas Warna dan Kontras',
        'Reusabilitas Elemen Desain',
        'Menggunakan font yang berbeda di setiap halaman',
      ],
      correctAnswerIndex: 3,
      points: 20,
    ),
    _SampleQuestion(
      question:
          'Protokol HTTP status code manakah yang menandakan permintaan berhasil (OK)?',
      answers: [
        '200 OK',
        '404 Not Found',
        '500 Internal Server Error',
        '301 Moved Permanently',
      ],
      correctAnswerIndex: 0,
      points: 20,
    ),
  ];

  static const List<Color> _kahootColors = [
    Color(0xFFE21B3C), // Red
    Color(0xFF1368CE), // Blue
    Color(0xFFD89E00), // Yellow
    Color(0xFF26890C), // Green
  ];

  static const List<String> _kahootSymbols = ['▲', '◆', '●', '■'];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuestions != null && widget.initialQuestions!.isNotEmpty) {
      _activeQuestions = widget.initialQuestions!.map((q) {
        final answers = q.pilihan.map((p) => p.teksPilihan).toList();
        while (answers.length < 4) {
          answers.add('');
        }
        return _SampleQuestion(
          question: q.pertanyaan,
          answers: answers,
          correctAnswerIndex: q.correctAnswerIndex >= 0 ? q.correctAnswerIndex : 0,
          points: q.poin,
        );
      }).toList();
    }
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = widget.timeLimitPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        if (!_isAnswerSubmitted) {
          _submitAnswer(-1); // Time out
        }
      }
    });
  }

  void _submitAnswer(int answerIndex) {
    if (_isAnswerSubmitted) return;
    _timer?.cancel();

    setState(() {
      _selectedAnswerIndex = answerIndex;
      _isAnswerSubmitted = true;

      final currentQ = _questions[_currentIndex];
      if (answerIndex == currentQ.correctAnswerIndex) {
        _correctCount++;
        _score += currentQ.points;
      }
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedAnswerIndex = null;
          _isAnswerSubmitted = false;
        });
        _startTimer();
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    final bool isLulus = _correctCount >= (_questions.length / 2);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isLulus
                        ? const Color(0xFFFEF3C7)
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      isLulus ? '🏆' : '💪',
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isLulus ? 'Quiz Selesai! 🎉' : 'Quiz Berakhir!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isLulus
                      ? 'Luar biasa! Pemahaman materi Anda sangat baik.'
                      : 'Tetap semangat, evaluasi dan coba lagi!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$_score',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF46178F),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'TOTAL POIN DIPEROLEH',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_correctCount / ${_questions.length}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF065F46),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Jawaban Benar',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLulus ? 'LULUS' : 'EVALUASI',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isLulus
                                    ? const Color(0xFF4338CA)
                                    : const Color(0xFFB45309),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Status Hasil',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // close dialog
                      Navigator.pop(context); // close preview
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kembali ke Kelola Quiz',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0B4FB3),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar Preview Notice & Exit
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF0A3875),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF08A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'MODE PREVIEW (ADMIN)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF854D0E),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Header Info & Timer
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: const BoxDecoration(
                color: Color(0xFF1368CE),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Soal ${_currentIndex + 1} / ${_questions.length}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
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
                          color: const Color(0xFF46178F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.mode == 'Wayground'
                              ? '⚡ Wayground'
                              : '⏱️ Kuis Biasa',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Animated Timer
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _remainingSeconds <= 5
                              ? const Color(0xFFE11D48)
                              : Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_remainingSeconds}s',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Progress indicator
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / _questions.length,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFBBF24),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            // Question Text Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'BOBOT: ${currentQ.points} POIN',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                widget.jenjang,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentQ.question,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Kahoot 4 Colors & Shapes Grid (2x2)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.35,
                      ),
                      itemCount: currentQ.answers.length,
                      itemBuilder: (context, index) {
                        final isCorrect =
                            index == currentQ.correctAnswerIndex;
                        final isSelected = _selectedAnswerIndex == index;

                        Color cardColor = _kahootColors[index];
                        if (_isAnswerSubmitted) {
                          if (isCorrect) {
                            cardColor = const Color(0xFF059669); // Green for correct
                          } else if (isSelected) {
                            cardColor = const Color(0xFFE11D48); // Red for wrong
                          } else {
                            cardColor = cardColor.withValues(alpha: 0.35);
                          }
                        }

                        return InkWell(
                          onTap: _isAnswerSubmitted
                              ? null
                              : () => _submitAnswer(index),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: cardColor.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: isSelected ? 3 : 0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _kahootSymbols[index],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_isAnswerSubmitted && isCorrect)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    else if (_isAnswerSubmitted && isSelected)
                                      const Icon(
                                        Icons.cancel,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  currentQ.answers[index],
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SampleQuestion {
  final String question;
  final List<String> answers;
  final int correctAnswerIndex;
  final int points;

  _SampleQuestion({
    required this.question,
    required this.answers,
    required this.correctAnswerIndex,
    required this.points,
  });
}
