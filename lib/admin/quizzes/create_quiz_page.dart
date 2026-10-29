import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/quiz_model.dart';
import 'models/quiz_question.dart';
import 'providers/quiz_provider.dart';
import 'widgets/quiz_header.dart';
import 'widgets/quiz_navigation.dart';
import 'widgets/quiz_properties.dart';
import 'widgets/quiz_question_editor.dart';

class CreateQuizPage extends StatefulWidget {
  final QuizModel? quizToEdit;

  const CreateQuizPage({super.key, this.quizToEdit});

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final TextEditingController _titleController = TextEditingController();

  int _currentQuestion = 0;

  final List<QuizQuestion> _questions = [];

  QuizQuestion get _question {
    if (_questions.isEmpty) return QuizQuestion();
    return _questions[_currentQuestion];
  }

  bool get _isEditing => widget.quizToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final q = widget.quizToEdit!;
      _titleController.text = q.judul;
      if (q.soal.isNotEmpty) {
        for (final item in q.soal) {
          final choices = item.pilihan.map((p) => p.teksPilihan).toList();
          while (choices.length < 4) {
            choices.add('');
          }
          _questions.add(
            QuizQuestion(
              question: item.pertanyaan,
              answers: choices,
              correctAnswer: item.correctAnswerIndex >= 0 ? item.correctAnswerIndex : 0,
              level: q.namaJenjang ?? 'SMA / MA / SMK Sederajat',
              difficulty: q.namaTingkat ?? 'Mudah',
              timeLimit: item.durasiDetik,
              points: item.poin,
            ),
          );
        }
      }
    }

    if (_questions.isEmpty) {
      _questions.add(QuizQuestion());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();

    for (final question in _questions) {
      question.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            QuizHeader(onSave: _saveQuiz),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 220),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    QuizTitleSection(
                      titleController: _titleController,
                      currentQuestion: _currentQuestion,
                      totalQuestions: _questions.length,
                      timeLimit: _question.timeLimit,
                      points: _question.points,
                    ),
                    const SizedBox(height: 14),
                    QuizQuestionEditor(
                      question: _question,
                      onSelectCorrectAnswer: (index) {
                        setState(() {
                          _question.correctAnswer = index;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    QuizProperties(
                      question: _question,
                      onChangedLevel: (level) {
                        setState(() {
                          _question.level = level;
                        });
                      },
                      onChangedDifficulty: (difficulty) {
                        setState(() {
                          _question.difficulty = difficulty;
                        });
                      },
                      onChangedTimeLimit: (timeLimit) {
                        setState(() {
                          _question.timeLimit = timeLimit;
                        });
                      },
                      onChangedPoints: (points) {
                        setState(() {
                          _question.points = points;
                        });
                      },
                      onChangedNeverExpire: (neverExpire) {
                        setState(() {
                          _question.neverExpire = neverExpire;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildQuestionActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: QuizNavigation(
        totalQuestions: _questions.length,
        currentQuestion: _currentQuestion,
        onSelectQuestion: (index) {
          setState(() {
            _currentQuestion = index;
          });
        },
        onAddQuestion: _addQuestion,
      ),
    );
  }

  Widget _buildQuestionActions() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _duplicateQuestion,
              icon: const Icon(Icons.content_copy, size: 16),
              label: const Text('Gandakan', style: TextStyle(fontSize: 10)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF475569),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _deleteQuestion,
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Hapus Soal', style: TextStyle(fontSize: 10)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFBE123C),
                backgroundColor: const Color(0xFFFFF1F2),
                side: const BorderSide(color: Color(0xFFFECACA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addQuestion() {
    setState(() {
      _questions.add(QuizQuestion());
      _currentQuestion = _questions.length - 1;
    });
  }

  void _duplicateQuestion() {
    final original = _question;

    final copy = QuizQuestion(
      question: original.questionController.text,
      answers: original.answers.map((controller) => controller.text).toList(),
      correctAnswer: original.correctAnswer,
      level: original.level,
      difficulty: original.difficulty,
      timeLimit: original.timeLimit,
      points: original.points,
      neverExpire: original.neverExpire,
    );

    setState(() {
      _questions.insert(_currentQuestion + 1, copy);
      _currentQuestion++;
    });
  }

  void _deleteQuestion() {
    if (_questions.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal harus ada 1 soal.')),
      );
      return;
    }

    setState(() {
      final removed = _questions.removeAt(_currentQuestion);
      removed.dispose();

      if (_currentQuestion >= _questions.length) {
        _currentQuestion = _questions.length - 1;
      }
    });
  }

  void _saveQuiz() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul kuis tidak boleh kosong! Silakan isi judul kuis terlebih dahulu.'),
          backgroundColor: Color(0xFFE11D48),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
              Text(
                _isEditing ? 'Perbarui Kuis' : 'Pilih Mode Simpan',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isEditing
                    ? 'Tentukan status perubahan kuis saat disimpan ke database.'
                    : 'Tentukan status kuis saat disimpan ke dalam sistem.',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                ),
                tileColor: const Color(0xFFECFDF5),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.send_rounded, color: Color(0xFF059669), size: 22),
                ),
                title: Text(
                  _isEditing ? 'Simpan & Publikasikan' : 'Publikasikan Sekarang',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF065F46)),
                ),
                subtitle: const Text(
                  'Kuis berstatus "Tersedia" dan langsung bisa dikerjakan oleh siswa.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF047857)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _submitQuiz(isDraft: false);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                tileColor: const Color(0xFFF8FAFC),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF64748B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_note, color: Color(0xFF475569), size: 22),
                ),
                title: const Text(
                  'Simpan sebagai Draf',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B)),
                ),
                subtitle: const Text(
                  'Kuis berstatus "Draft" dan belum bisa dilihat oleh siswa.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _submitQuiz(isDraft: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitQuiz({required bool isDraft}) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final jenjangMap = {
      'SD / MI': 1,
      'SMP / MTs': 2,
      'SMA / MA / SMK Sederajat': 3,
      'Perguruan Tinggi / Umum': 4,
    };

    final difficultyMap = {
      'Mudah': 1,
      'Sedang': 2,
      'Sulit': 3,
    };

    final labels = ['A', 'B', 'C', 'D'];

    final soalList = _questions.map((q) {
      final qText = q.questionController.text.trim();
      return {
        'pertanyaan': qText.isEmpty ? 'Pertanyaan' : qText,
        'jenis_soal': 'kuis',
        'poin': q.points,
        'durasi_detik': q.timeLimit,
        'pilihan': List.generate(4, (i) {
          final text = i < q.answers.length ? q.answers[i].text.trim() : '';
          return {
            'label': labels[i],
            'teks_pilihan': text,
            'is_correct': q.correctAnswer == i,
          };
        }),
      };
    }).toList();

    final payload = {
      'judul': title,
      'id_jenjang': jenjangMap[_question.level] ?? 3,
      'id_tingkatquiz': difficultyMap[_question.difficulty] ?? 1,
      'mode_pengerjaan': 'wayground',
      'action_type': isDraft ? 'draft' : 'publish',
      'soal': soalList,
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Card(
          elevation: 6,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(strokeWidth: 3),
                const SizedBox(width: 16),
                Text(
                  _isEditing ? 'Memperbarui kuis...' : 'Menyimpan kuis...',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final quizProvider = context.read<QuizProvider>();
      final bool success = _isEditing
          ? await quizProvider.updateQuiz(widget.quizToEdit!.idQuiz, payload)
          : await quizProvider.createQuiz(payload);

      if (mounted) {
        Navigator.pop(context);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Kuis "$title" berhasil diperbarui!'
                    : (isDraft ? 'Kuis berhasil disimpan sebagai Draf!' : 'Kuis berhasil dipublikasikan!'),
              ),
              backgroundColor: const Color(0xFF059669),
            ),
          );
          Navigator.pop(context);
        } else {
          final err = quizProvider.error ?? 'Terjadi kesalahan sistem.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan: $err'),
              backgroundColor: const Color(0xFFE11D48),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi error: $e'),
            backgroundColor: const Color(0xFFE11D48),
          ),
        );
      }
    }
  }
}
