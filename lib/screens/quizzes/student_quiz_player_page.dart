import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/quizzes/models/quiz_model.dart';
import '../../admin/quizzes/providers/quiz_provider.dart';
import '../../admin/quizzes/repositories/quiz_repository.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/audio_service.dart';
import '../../core/storage/preferences_service.dart';

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

  int _remainingSeconds = 20;
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
  bool get _isLastQuestion => _currentIndex >= _questions.length - 1;

  @override
  void initState() {
    super.initState();
    AudioService.syncPreferences();
    _questions = widget.quiz.soal;
    if (_questions.isNotEmpty) {
      _remainingSeconds =
          _currentQ.durasiDetik > 0 ? _currentQ.durasiDetik : 20;
    }
    if (_questions.isEmpty) {
      _loadQuestionsFromApi();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndPromptDraft();
      });
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkAndPromptDraft();
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingQuestions = false);
      }
    }
  }

  Future<void> _checkAndPromptDraft() async {
    final draft = await PreferencesService.getQuizDraft(widget.quiz.idQuiz);
    if (!mounted) return;

    if (draft != null && draft['answers'] != null) {
      final answers = draft['answers'] as Map<int, String>;
      if (answers.isNotEmpty) {
        final int draftIndex = (draft['currentIndex'] as int? ?? 0).clamp(0, _questions.length - 1);
        final int? savedRemaining = draft['remainingSeconds'] as int?;

        final restore = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.history_rounded, color: Color(0xFF2563EB), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Lanjutkan Kuis?',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                ),
              ],
            ),
            content: Text(
              'Ditemukan draft pengerjaan sebelumnya (${answers.length} soal sudah dijawab).\n\nApakah Anda ingin melanjutkan pengerjaan atau mulai ulang dari awal?',
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF475569), height: 1.45),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Mulai Ulang', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Lanjutkan', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );

        if (!mounted) return;

        if (restore == true) {
          setState(() {
            _studentAnswers.addAll(answers);
            _currentIndex = draftIndex;
            if (!_isWayground && savedRemaining != null && savedRemaining > 0) {
              _totalRemainingSeconds = savedRemaining;
            }
          });
          _syncCurrentQuestionState();
          _startQuizTimers();
          return;
        } else {
          await PreferencesService.clearQuizDraft(widget.quiz.idQuiz);
        }
      }
    }

    _startQuizTimers();
  }

  void _syncCurrentQuestionState() {
    final existingAnswer = _studentAnswers[_currentQ.idSoal ?? _currentIndex];
    if (existingAnswer != null && existingAnswer.isNotEmpty) {
      _isAnswerSubmittedForCurrentQ = true;
      if (_currentQ.jenisSoal == JenisSoal.isianSingkat) {
        _essayController.text = existingAnswer;
      } else {
        final choices = _currentQ.pilihan;
        int foundIdx = -1;
        for (int i = 0; i < choices.length; i++) {
          if (choices[i].label.toUpperCase() == existingAnswer.toUpperCase()) {
            foundIdx = i;
            break;
          }
        }
        if (foundIdx == -1) {
          final lIdx = _kahootLabels.indexOf(existingAnswer.toUpperCase());
          if (lIdx != -1) foundIdx = lIdx;
        }
        _selectedChoiceIndex = foundIdx != -1 ? foundIdx : null;
      }
    } else {
      _selectedChoiceIndex = null;
      _essayController.clear();
      _isAnswerSubmittedForCurrentQ = false;
    }
  }

  void _saveDraft() {
    PreferencesService.saveQuizDraft(
      quizId: widget.quiz.idQuiz,
      answers: _studentAnswers,
      currentIndex: _currentIndex,
      remainingSeconds: _totalRemainingSeconds,
    );
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
    if (_totalRemainingSeconds == null) {
      final menit = widget.quiz.durasiTotalMenit ?? 30;
      _totalRemainingSeconds = menit * 60;
    }
    _totalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalRemainingSeconds! > 0) {
        if (mounted) {
          setState(() => _totalRemainingSeconds = _totalRemainingSeconds! - 1);
          if (_totalRemainingSeconds! % 10 == 0) {
            _saveDraft();
          }
        }
      } else {
        _totalTimer?.cancel();
        _finishAndSubmitQuiz();
      }
    });
  }

  void _handleTimeOut() {
    AudioService.playErrorSound();
    AudioService.triggerHaptic();

    _isAnswerSubmittedForCurrentQ = true;
    _studentAnswers[_currentQ.idSoal ?? _currentIndex] = '';
    _saveDraft();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      _advanceToNext();
    });
  }

  void _selectAnswer(int choiceIndex, {String? customLabel}) {
    if (_isSubmittingFinal) return;

    AudioService.playTapSound();
    AudioService.triggerHaptic();

    final choices = _currentQ.pilihan;
    final label = customLabel ??
        (choiceIndex < choices.length
            ? choices[choiceIndex].label
            : (choiceIndex < _kahootLabels.length
                ? _kahootLabels[choiceIndex]
                : 'A'));
    _studentAnswers[_currentQ.idSoal ?? _currentIndex] = label;
    _saveDraft();

    setState(() {
      _selectedChoiceIndex = choiceIndex;
      _isAnswerSubmittedForCurrentQ = true;
    });

    if (_isWayground) {
      _timer?.cancel();
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        _advanceToNext();
      });
    }
  }

  void _goToQuestion(int index) {
    if (index < 0 || index >= _questions.length) return;
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });
    _syncCurrentQuestionState();
    if (_isWayground) {
      _startQuestionTimer();
    }
  }

  void _submitEssayAnswer() {
    if (_isAnswerSubmittedForCurrentQ || _isSubmittingFinal) return;
    final answerText = _essayController.text.trim();
    if (answerText.isEmpty) return;

    AudioService.playTapSound();
    AudioService.triggerHaptic();

    _studentAnswers[_currentQ.idSoal ?? _currentIndex] = answerText;
    _saveDraft();

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
      _syncCurrentQuestionState();
      _saveDraft();
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
        await PreferencesService.clearQuizDraft(widget.quiz.idQuiz);
        AudioService.playCompletionSound();
        _showResultDialog(result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim jawaban ke server. Draft pengerjaan tetap tersimpan aman.')),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gold Trophy Badge (Khas Elearning Arrava)
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🏆', style: TextStyle(fontSize: 38)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Quiz Selesai!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Berikut adalah hasil pencapaian Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),

                // Score Box (Poin Didapat)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${res.poinDiberikan}',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF4F46E5),
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'POIN DIDAPAT',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 2 Grid Stat Cards: Jawaban Benar & Total Soal
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${res.benar}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF047857),
                              ),
                            ),
                            const SizedBox(height: 1),
                            const Text(
                              'JAWABAN BENAR',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF059669),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_questions.length}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4338CA),
                              ),
                            ),
                            const SizedBox(height: 1),
                            const Text(
                              'TOTAL SOAL',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4F46E5),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Button Kembali ke Dashboard (slate-900 ala elearningarrava)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Kembali ke Dashboard',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
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

  void _showAudioSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.tune_rounded, color: Color(0xFF2563EB), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Pengaturan Kuis',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder<bool>(
                  future: PreferencesService.isSoundEnabled(),
                  builder: (context, snapshot) {
                    final isSound = snapshot.data ?? true;
                    return SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(Icons.volume_up_rounded, color: Color(0xFF2563EB)),
                      title: const Text('Efek Suara (SFX)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: const Text('Suara tombol dan notifikasi kuis', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      value: isSound,
                      activeThumbColor: const Color(0xFF2563EB),
                      onChanged: (val) async {
                        await PreferencesService.setSoundEnabled(val);
                        await AudioService.syncPreferences();
                        setSheetState(() {});
                      },
                    );
                  },
                ),
                const Divider(),
                FutureBuilder<bool>(
                  future: PreferencesService.isHapticEnabled(),
                  builder: (context, snapshot) {
                    final isHaptic = snapshot.data ?? true;
                    return SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(Icons.vibration_rounded, color: Color(0xFF10B981)),
                      title: const Text('Getaran (Haptic Feedback)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: const Text('Getar lembut saat memilih opsi jawaban', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      value: isHaptic,
                      activeThumbColor: const Color(0xFF10B981),
                      onChanged: (val) async {
                        await PreferencesService.setHapticEnabled(val);
                        await AudioService.syncPreferences();
                        if (val) AudioService.triggerHaptic();
                        setSheetState(() {});
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_done_rounded, size: 18, color: Color(0xFF059669)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_studentAnswers.length} dari ${_questions.length} soal tersimpan otomatis.',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Keluar dari Kuis?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Text(
          'Progres pengerjaanmu (${_studentAnswers.length} dari ${_questions.length} soal) tersimpan otomatis sebagai draft.\n\nKamu dapat melanjutkannya kapan saja.',
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF475569), height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Lanjutkan Kuis', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Keluar (Simpan Draft)', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingQuestions) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF4F46E5)),
              SizedBox(height: 16),
              Text(
                'Memuat butir soal dari database...',
                style: TextStyle(
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
          title: const Text(
            'Kuis Kosong',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        body: const Center(
          child: Text(
            'Kuis ini belum memiliki butir soal di database.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final currentQ = _currentQ;
    final choices = currentQ.pilihan;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. TOP HEADER (Mirip Elearning Arrava Web)
            _buildTopHeader(),

            // 2. SLIM PROGRESS BAR
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4F46E5),
              ),
              minHeight: 4,
            ),

            // 3. MAIN SCROLLABLE QUESTION & ANSWER AREA
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Kartu Soal Utama
                        _buildQuestionCard(currentQ),

                        const SizedBox(height: 16),

                        // Area Pilihan Jawaban
                        _buildAnswerArea(currentQ, choices),

                        // Navigasi Nomor Soal
                        _buildQuestionNavStrip(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 4. BOTTOM DOCKED CONTROLS
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE0E7FF)),
            ),
            child: Text(
              _isWayground ? 'Mode Waktu per Soal' : 'Mode Waktu Total',
              style: const TextStyle(
                color: Color(0xFF4338CA),
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.quiz.judul,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Total: ${_questions.length} Pertanyaan',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.volume_up_rounded,
              color: Color(0xFF64748B),
              size: 20,
            ),
            tooltip: 'Pengaturan Suara',
            onPressed: _showAudioSettingsSheet,
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: _showExitConfirmationDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close_rounded, size: 14, color: Color(0xFFBE123C)),
                  SizedBox(width: 4),
                  Text(
                    'Keluar',
                    style: TextStyle(
                      color: Color(0xFFBE123C),
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionModel currentQ) {
    final String? resolvedFotoUrl = ApiConstants.resolveMediaUrl(currentQ.fotoSoal);
    final String typeLabel = currentQ.jenisSoal == JenisSoal.trueFalse
        ? 'Benar atau Salah'
        : (currentQ.jenisSoal == JenisSoal.isianSingkat ? 'Isian Singkat' : 'Pilihan Ganda');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top badges: Nomor Soal, Jenis Soal, XP & Timer (Mirip Elearning Arrava)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE0E7FF)),
                ),
                child: Text(
                  'Pertanyaan No. ${_currentIndex + 1} / ${_questions.length}',
                  style: const TextStyle(
                    color: Color(0xFF4F46E5),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    typeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, size: 13, color: Color(0xFFD97706)),
                    const SizedBox(width: 2),
                    Text(
                      '+${currentQ.poin} XP',
                      style: const TextStyle(
                        color: Color(0xFFB45309),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isWayground) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _remainingSeconds <= 5
                        ? const Color(0xFFFFE4E6)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '⏱️ ${_remainingSeconds}s',
                    style: TextStyle(
                      color: _remainingSeconds <= 5
                          ? const Color(0xFFE11D48)
                          : const Color(0xFF475569),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // Elearning Arrava Dark Navy Question Box (bg-slate-900)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '"${currentQ.pertanyaan}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                height: 1.45,
              ),
            ),
          ),

          // Foto Soal (Opsional, jika ada gambar)
          if (resolvedFotoUrl != null) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => _showFullImage(context, resolvedFotoUrl),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: Image.network(
                          resolvedFotoUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Padding(
                              padding: EdgeInsets.all(28),
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4F46E5)),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            padding: const EdgeInsets.all(20),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.broken_image_rounded, color: Color(0xFF94A3B8), size: 30),
                                SizedBox(height: 4),
                                Text(
                                  'Gambar soal tidak dapat dimuat',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Perbesar',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
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
          color: const Color(0xFFEEF2FF), // bg-indigo-50
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC7D2FE)), // border-indigo-200
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('✍️', style: TextStyle(fontSize: 14)),
                SizedBox(width: 6),
                Text(
                  'KETIKKAN JAWABAN ISIAN SINGKAT ANDA:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF312E81),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _essayController,
              enabled: !_isAnswerSubmittedForCurrentQ,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Ketikkan jawaban Anda di sini...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFA5B4FC)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFA5B4FC)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAnswerSubmittedForCurrentQ ? null : _submitEssayAnswer,
                icon: const Icon(Icons.send_rounded, size: 16),
                label: Text(
                  _isAnswerSubmittedForCurrentQ ? 'Jawaban Tersimpan ✓' : 'Kirim Jawaban Singkat',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
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

      return Column(
        children: [
          _buildChoiceCard(
            index: 0,
            label: optA.label,
            symbol: '▲',
            text: optA.teksPilihan,
            badgeColor: const Color(0xFF26890C), // Green for Benar
          ),
          _buildChoiceCard(
            index: 1,
            label: optB.label,
            symbol: '◆',
            text: optB.teksPilihan,
            badgeColor: const Color(0xFFE21B3C), // Red for Salah
          ),
        ],
      );
    }

    // 3. Pilihan Ganda (Kahoot-like cards vertical list)
    return Column(
      children: List.generate(choices.length, (index) {
        final opt = choices[index];
        final color = _kahootColors[index % _kahootColors.length];
        final symbol = _kahootSymbols[index % _kahootSymbols.length];
        final label = opt.label.isNotEmpty
            ? opt.label
            : (index < _kahootLabels.length ? _kahootLabels[index] : '${index + 1}');

        return _buildChoiceCard(
          index: index,
          label: label,
          symbol: symbol,
          text: opt.teksPilihan,
          badgeColor: color,
        );
      }),
    );
  }

  Widget _buildChoiceCard({
    required int index,
    required String label,
    required String symbol,
    required String text,
    required Color badgeColor,
  }) {
    final bool isSelected = _selectedChoiceIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectAnswer(index, customLabel: label),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                width: isSelected ? 2.0 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? const Color(0xFF4F46E5).withValues(alpha: 0.12)
                      : const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Shape Badge (A/B/C/D dengan simbol Kahoot)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    symbol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Teks Jawaban
                Expanded(
                  child: Text(
                    text.isEmpty ? 'Pilihan $label' : text,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF4338CA) : const Color(0xFF1E293B),
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Selection Indicator (Radio Bulat dengan Checkmark)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 15)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionNavStrip() {
    final int answeredCount = _studentAnswers.length;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NAVIGASI SOAL',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '$answeredCount/${_questions.length} Terjawab',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_questions.length, (i) {
                final bool isCurrent = i == _currentIndex;
                final bool isAnswered = _studentAnswers.containsKey(_questions[i].idSoal ?? i);

                Color bgColor = const Color(0xFFF1F5F9);
                Color textColor = const Color(0xFF64748B);
                Border? border;

                if (isCurrent) {
                  bgColor = const Color(0xFF4F46E5);
                  textColor = Colors.white;
                  border = Border.all(color: const Color(0xFF4338CA), width: 1.5);
                } else if (isAnswered) {
                  bgColor = const Color(0xFFECFDF5);
                  textColor = const Color(0xFF059669);
                  border = Border.all(color: const Color(0xFFA7F3D0));
                }

                return InkWell(
                  onTap: () => _goToQuestion(i),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: border,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Tombol Sebelumnya (Khusus jika bukan soal pertama)
            if (_currentIndex > 0) ...[
              OutlinedButton.icon(
                onPressed: () => _goToQuestion(_currentIndex - 1),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text(
                  'Sebelumnya',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF475569),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 10),
            ],

            const Spacer(),

            // Tombol Selanjutnya / Submit
            if (_isLastQuestion)
              ElevatedButton.icon(
                onPressed: _isSubmittingFinal ? null : () => _finishAndSubmitQuiz(),
                icon: _isSubmittingFinal
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('🚀', style: TextStyle(fontSize: 15)),
                label: Text(
                  _isSubmittingFinal ? 'Mengirim...' : 'Kumpulkan Jawaban Saya',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => _goToQuestion(_currentIndex + 1),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text(
                  'Soal Selanjutnya',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
