import 'package:flutter/material.dart';

class QuizQuestion {
  final TextEditingController questionController;
  final List<TextEditingController> answers;
  int correctAnswer;
  String level;
  String difficulty;
  int timeLimit;
  int points;
  bool neverExpire;

  QuizQuestion({
    String question = '',
    List<String> answers = const ['', '', '', ''],
    this.correctAnswer = 0,
    this.level = 'SMA / MA / SMK Sederajat',
    this.difficulty = 'Mudah',
    this.timeLimit = 20,
    this.points = 10,
    this.neverExpire = true,
  })  : questionController = TextEditingController(text: question),
        answers = answers
            .map((answer) => TextEditingController(text: answer))
            .toList();

  void dispose() {
    questionController.dispose();
    for (final controller in answers) {
      controller.dispose();
    }
  }
}
