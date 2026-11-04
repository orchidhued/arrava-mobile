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
    AudioService.syncPreferences();
    _questions = widget.quiz.soal;
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
    if (_isAnswerSubmittedForCurrentQ || _isSubmittingFinal) return;

    AudioService.playTapSound();
    AudioService.triggerHaptic();

    final choices = _currentQ.pilihan;
    final label = customLabel ?? (choiceIndex < choices.length ? choices[choiceIndex].label : (choiceIndex < _kahootLabels.length ? _kahootLabels[choiceIndex] : 'A'));
    _studentAnswers[_currentQ.idSoal ?? _currentIndex] = label;
    _saveDraft();

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
                    icon: const Icon(Icons.volume_up_rounded, color: Colors.white70, size: 20),
                    tooltip: 'Pengaturan Suara',
                    onPressed: _showAudioSettingsSheet,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    tooltip: 'Keluar',
                    onPressed: _showExitConfirmationDialog,
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

            // Question Card & Interactive Answer Area (Responsive side-by-side pada layar besar)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth >= 700;

                  if (isWideScreen) {
                    // LAYAR BESAR / TABLET / LANDSCAPE: Soal dan Jawaban Bersebelahan!
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Kolom Kiri: Kartu Soal
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
                            child: _buildQuestionCard(currentQ),
                          ),
                        ),
                        // Kolom Kanan: Area Pilihan Jawaban
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
                            child: _buildAnswerArea(currentQ, choices),
                          ),
                        ),
                      ],
                    );
                  }

                  // LAYAR HP / PORTRAIT: Bertumpuk Atas-Bawah
                  return Column(
                    children: [
                      Expanded(
                        flex: (currentQ.fotoSoal != null &&
                                currentQ.fotoSoal!.trim().isNotEmpty)
                            ? 5
                            : 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: _buildQuestionCard(currentQ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                          child: _buildAnswerArea(currentQ, choices),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Badges row: Question number, type, points
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Soal ${_currentIndex + 1} / ${_questions.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    typeLabel,
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt, size: 12, color: Color(0xFFD97706)),
                      const SizedBox(width: 2),
                      Text(
                        '+${currentQ.poin} XP',
                        style: const TextStyle(
                          color: Color(0xFFB45309),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Foto Soal (jika ada)
            if (resolvedFotoUrl != null) ...[
              GestureDetector(
                onTap: () => _showFullImage(context, resolvedFotoUrl),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 145),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Center(
                          child: Image.network(
                            resolvedFotoUrl,
                            fit: BoxFit.contain,
                            height: 145,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const SizedBox(
                                height: 120,
                                child: Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 100,
                              color: const Color(0xFFF8FAFC),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image_rounded, color: Color(0xFF94A3B8), size: 28),
                                    SizedBox(height: 4),
                                    Text('Gambar soal tidak tersedia', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_in_rounded, color: Colors.white, size: 13),
                            SizedBox(width: 3),
                            Text(
                              'Perbesar',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Teks Pertanyaan
            Text(
              currentQ.pertanyaan,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: (resolvedFotoUrl != null) ? 15 : 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                height: 1.4,
              ),
            ),
          ],
        ),
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
