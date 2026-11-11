import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'quiz_model.dart';

class QuizQuestion {
  final TextEditingController questionController;
  final TextEditingController shortAnswerController;
  final List<TextEditingController> answers;
  JenisSoal jenisSoal;
  int correctAnswer;
  int timeLimit;
  int points;

  // Foto soal
  String? existingFotoUrl;
  Uint8List? fotoBytes;
  String? fotoName;
  bool removeFoto;

  // Legacy/fallback properties
  String level;
  int? idMapel;
  String? namaMapel;
  String difficulty;
  bool neverExpire;

  QuizQuestion({
    String question = '',
    String shortAnswer = '',
    List<String> answers = const ['', '', '', ''],
    this.jenisSoal = JenisSoal.kuis,
    this.correctAnswer = 0,
    this.timeLimit = 20,
    this.points = 10,
    this.existingFotoUrl,
    this.fotoBytes,
    this.fotoName,
    this.removeFoto = false,
    this.level = 'SMA / MA / SMK Sederajat',
    this.idMapel,
    this.namaMapel,
    this.difficulty = 'Mudah',
    this.neverExpire = true,
  })  : questionController = TextEditingController(text: question),
        shortAnswerController = TextEditingController(text: shortAnswer),
        answers = answers
            .map((answer) => TextEditingController(text: answer))
            .toList();

  QuizQuestion copy() {
    return QuizQuestion(
      question: questionController.text,
      shortAnswer: shortAnswerController.text,
      answers: answers.map((controller) => controller.text).toList(),
      jenisSoal: jenisSoal,
      correctAnswer: correctAnswer,
      timeLimit: timeLimit,
      points: points,
      existingFotoUrl: existingFotoUrl,
      fotoBytes: fotoBytes,
      fotoName: fotoName,
      removeFoto: removeFoto,
      level: level,
      idMapel: idMapel,
      namaMapel: namaMapel,
      difficulty: difficulty,
      neverExpire: neverExpire,
    );
  }

  void dispose() {
    questionController.dispose();
    shortAnswerController.dispose();
    for (final controller in answers) {
      controller.dispose();
    }
  }
}
