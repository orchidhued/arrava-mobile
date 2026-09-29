import 'package:flutter/material.dart';

import 'models/quiz_question.dart';
import 'widgets/quiz_header.dart';
import 'widgets/quiz_navigation.dart';
import 'widgets/quiz_properties.dart';
import 'widgets/quiz_question_editor.dart';

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key});

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final TextEditingController _titleController = TextEditingController();

  int _currentQuestion = 0;

  final List<QuizQuestion> _questions = [QuizQuestion()];

  QuizQuestion get _question {
    return _questions[_currentQuestion];
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quiz berhasil disimpan sebagai draft.')),
    );
  }
}
