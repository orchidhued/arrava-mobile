import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/quizzes/models/quiz_model.dart';
import '../../admin/quizzes/providers/quiz_provider.dart';
import '../../admin/quizzes/repositories/quiz_repository.dart';

class StudentQuizPlayerPage extends StatefulWidget {
  final QuizModel quiz;

  const StudentQuizPlayerPage({super.key, required this.quiz});

  @override
  State<StudentQuizPlayerPage> createState() => _StudentQuizPlayerPageState();
}

class _StudentQuizPlayerPageState extends State<StudentQuizPlayerPage> {
  int _currentIndex = 0;
  final Map<int, String> _studentAnswers = {}; // id_soal => jawaban ('A', 'B', ...)
  int? _selectedChoiceIndex;
  bool _isAnswerSubmittedForCurrentQ = false;
  bool _isSubmittingFinal = false;

  late int _remainingSeconds;
  Timer? _timer;

  // Total timer untuk Mode Biasa
  int? _totalRemainingSeconds;
  Timer? _totalTimer;

  // Soal state
  List<QuestionModel> _questions = [];
  bool _isLoadingQuestions = false;
  final TextEditingController _essayController = TextEditingController();

  static const List<Color> _kahootColors = [
    Color(0xFFE21B3C), // A - Red
    Color(0xFF1368CE), // B - Blue
    Color(0xFFD89E00), // C - Yellow
    Color(0xFF26890C), // D - Green
  ];

  static const List<String> _kahootSymbols = ['▲', '◆', '●', '■'];
  static const List<String> _kahootLabels = ['A', 'B', 'C', 'D'];

  QuestionModel get _currentQ {
    if (_questions.isEmpty) {
      return const QuestionModel(pertanyaan: 'Soal tidak ditemukan');
    }
    return _questions[_currentIndex];
  }

  bool get _isWayground => widget.quiz.isWayground;

  @override
  void initState() {
    super.initState();
    _questions = widget.quiz.soal;
    if (_questions.isEmpty) {
      _loadQuestionsFromApi();
    } else {
      _startQuizTimers();
    }
  }

  Future<void> _loadQuestionsFromApi() async {
    setState(() => _isLoadingQuestions = true);
    try {
      final freshQuiz = await QuizRepository().getQuizById(widget.quiz.idQuiz);
      if (mounted) {
        setState(() {
          _questions = freshQuiz.soal;
          _isLoadingQuestions = false;
        });
        if (_questions.isNotEmpty) {
          _startQuizTimers();
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingQuestions = false);
      }
    }
  }

  void _startQuizTimers() {
    if (_questions.isEmpty) return;
    if (_isWayground) {
      _startQuestionTimer();
    } else {
      _startTotalTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _totalTimer?.cancel();
    _essayController.dispose();
    super.dispose();
  }

  void _startQuestionTimer() {
    _timer?.cancel();
    _remainingSeconds = _currentQ.durasiDetik > 0 ? _currentQ.durasiDetik : 20;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        if (!_isAnswerSubmittedForCurrentQ) {
          _handleTimeOut();
        }
      }
    });
  }

  void _startTotalTimer() {
    final menit = widget.quiz.durasiTotalMenit ?? 30;
    _totalRemainingSeconds = menit * 60;
    _totalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalRemainingSeconds! > 0) {
        if (mounted) setState(() => _totalRemainingSeconds = _totalRemainingSeconds! - 1);
      } else {
        _totalTimer?.cancel();
        _finishAndSubmitQuiz();
      }
    });
  }

  void _handleTimeOut() {
    _isAnswerSubmittedForCurrentQ = true;
    _studentAnswers[_currentQ.idSoal ?? _currentIndex] = '';

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      _advanceToNext();
    });
  }

  void _selectAnswer(int choiceIndex, {String? customLabel}) {
    if (_isAnswerSubmittedForCurrentQ || _isSubmittingFinal) return;

    final choices = _currentQ.pilihan;
    final label = customLabel ?? (choiceIndex < choices.length ? choices[choiceIndex].label : (choiceIndex < _kahootLabels.length ? _kahootLabels[choiceIndex] : 'A'));
    _studentAnswers[_currentQ.idSoal ?? _currentIndex] = label;

    setState(() {
      _selectedChoiceIndex = choiceIndex;
      _isAnswerSubmittedForCurrentQ = true;
    });

    if (_isWayground) {
      _timer?.cancel();
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        _advanceToNext();
      });
    }
  }

  void _submitEssayAnswer() {
    if (_isAnswerSubmittedForCurrentQ || _isSubmittingFinal) return;
    final answerText = _essayController.text.trim();
    if (answerText.isEmpty) return;

    _studentAnswers[_currentQ.idSoal ?? _currentIndex] = answerText;

    setState(() {
      _isAnswerSubmittedForCurrentQ = true;
    });

    if (_isWayground) {
      _timer?.cancel();
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        _advanceToNext();
      });
    }
  }

  void _advanceToNext() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedChoiceIndex = null;
        _isAnswerSubmittedForCurrentQ = false;
        _essayController.clear();
      });
      if (_isWayground) {
        _startQuestionTimer();
      }
    } else {
      _finishAndSubmitQuiz();
    }
  }

  Future<void> _finishAndSubmitQuiz() async {
    _timer?.cancel();
    _totalTimer?.cancel();

    if (_isSubmittingFinal) return;
    setState(() => _isSubmittingFinal = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(strokeWidth: 3),
                SizedBox(width: 16),
                Text(
                  'Mengirim jawaban ke server...',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final provider = context.read<QuizProvider>();
    final result = await provider.submitQuiz(widget.quiz.idQuiz, _studentAnswers);

    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      if (result != null) {
        _showResultDialog(result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim jawaban ke server.')),
        );
      }
    }
  }

  void _showResultDialog(QuizSubmissionResult res) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: res.isLulus ? const Color(0xFF10B981).withValues(alpha: 0.15) : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      res.isLulus ? '🎉' : '💪',
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  res.isLulus ? 'Selamat, Kamu Lulus! 🎉' : 'Tetap Semangat, Coba Lagi! 💪',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  res.isLulus
                      ? 'Kamu berhasil menyelesaikan kuis "${res.judul}" dengan hasil memuaskan!'
                      : 'Jangan berkecil hati, pelajari kembali materi kuis "${res.judul}" dan coba lagi!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric(
                        label: 'Nilai Akhir',
                        value: '${res.persentase.toInt()}%',
                        color: res.isLulus ? const Color(0xFF059669) : const Color(0xFFD97706),
                      ),
                      Container(width: 1, height: 32, color: const Color(0xFFCBD5E1)),
                      _buildMetric(
                        label: 'Benar / Salah',
                        value: '${res.benar} / ${res.salah}',
                        color: const Color(0xFF1E293B),
                      ),
                      Container(width: 1, height: 32, color: const Color(0xFFCBD5E1)),
                      _buildMetric(
                        label: 'Poin XP',
                        value: '+${res.poinDiberikan}',
                        color: const Color(0xFF2563EB),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx); // Close dialog
                      Navigator.pop(context); // Back to quiz list
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Kembali ke Beranda Kuis',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
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

  Widget _buildMetric({required String label, required String value, required Color color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingQuestions) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A2540),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Memuat butir soal dari database...',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A2540),
        appBar: AppBar(
          backgroundColor: const Color(0xFF071C33),
          foregroundColor: Colors.white,
          title: const Text('Kuis Kosong'),
        ),
        body: const Center(
          child: Text(
            'Kuis ini belum memiliki butir soal di database.',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ),
      );
    }

    final currentQ = _currentQ;
    final choices = currentQ.pilihan;

    return Scaffold(
      backgroundColor: const Color(0xFF0A2540), // Dark Kahoot-style navy background
      body: SafeArea(
        child: Column(
          children: [
            // Header Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF071C33),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF46178F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Arrava 360',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.quiz.judul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Keluar dari Kuis?'),
                          content: const Text('Progres pengerjaan saat ini tidak akan disimpan jika kamu keluar.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Lanjutkan'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Keluar', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Progress & Timer Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF0E3259),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Soal ${_currentIndex + 1} / ${_questions.length}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                      if (_isWayground)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: _remainingSeconds <= 5 ? Colors.redAccent : const Color(0xFFFACC15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer,
                                size: 14,
                                color: _remainingSeconds <= 5 ? Colors.white : const Color(0xFF0F172A),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$_remainingSeconds dtk',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  color: _remainingSeconds <= 5 ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_totalRemainingSeconds != null)
                        Text(
                          'Sisa Waktu: ${(_totalRemainingSeconds! ~/ 60).toString().padLeft(2, '0')}:${(_totalRemainingSeconds! % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Color(0xFFFACC15), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / _questions.length,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                    minHeight: 5,
                  ),
                ],
              ),
            ),

            // Question Card
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(
                        currentQ.pertanyaan,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Interactive Answer Area (Dynamic based on Question Type)
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                child: _buildAnswerArea(currentQ, choices),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerArea(QuestionModel currentQ, List<OptionModel> choices) {
    // 1. Isian Singkat
    if (currentQ.jenisSoal == JenisSoal.isianSingkat || choices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0E3259),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _essayController,
              enabled: !_isAnswerSubmittedForCurrentQ,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Ketik jawaban singkat di sini...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isAnswerSubmittedForCurrentQ ? null : _submitEssayAnswer,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  _isAnswerSubmittedForCurrentQ ? 'Jawaban Terkirim ✓' : 'Kirim Jawaban',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 2. Benar / Salah (True / False)
    if (currentQ.jenisSoal == JenisSoal.trueFalse || choices.length == 2) {
      final optA = choices.isNotEmpty ? choices[0] : const OptionModel(label: 'A', teksPilihan: 'Benar', isCorrect: true);
      final optB = choices.length > 1 ? choices[1] : const OptionModel(label: 'B', teksPilihan: 'Salah', isCorrect: false);

      return Row(
        children: [
          Expanded(
            child: _buildChoiceTile(
              index: 0,
              label: optA.label,
              symbol: '▲',
              text: optA.teksPilihan,
              color: const Color(0xFF10B981), // Green for Benar
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildChoiceTile(
              index: 1,
              label: optB.label,
              symbol: '◆',
              text: optB.teksPilihan,
              color: const Color(0xFFE21B3C), // Red for Salah
            ),
          ),
        ],
      );
    }

    // 3. Pilihan Ganda (Kuis 3-4 opsi)
    final itemCount = choices.length;
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.35,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(itemCount, (index) {
        final opt = choices[index];
        final color = _kahootColors[index % _kahootColors.length];
        final symbol = _kahootSymbols[index % _kahootSymbols.length];

        return _buildChoiceTile(
          index: index,
          label: opt.label,
          symbol: symbol,
          text: opt.teksPilihan,
          color: color,
        );
      }),
    );
  }

  Widget _buildChoiceTile({
    required int index,
    required String label,
    required String symbol,
    required String text,
    required Color color,
  }) {
    final bool isSelected = _selectedChoiceIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectAnswer(index, customLabel: label),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: Colors.white, width: 3.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    symbol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.white, size: 16),
                ],
              ),
              const Spacer(),
              Text(
                text.isEmpty ? 'Pilihan $label' : text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
