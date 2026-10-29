// =============================================================================
// quiz_provider.dart
// -----------------------------------------------------------------------------
// State management fitur Quiz memakai Provider (ChangeNotifier).
// =============================================================================

import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/quiz_model.dart';
import '../repositories/quiz_repository.dart';

class QuizProvider with ChangeNotifier {
  final QuizRepository _repository;

  QuizProvider({QuizRepository? repository})
      : _repository = repository ?? QuizRepository();

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  List<QuizModel> _quizzes = [];
  List<QuizModel> get quizzes => UnmodifiableListView(_quizzes);

  QuizModel? _selectedQuiz;
  QuizModel? get selectedQuiz => _selectedQuiz;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int _listRequestId = 0;
  bool _disposed = false;

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  String _cleanError(Object e) => e.toString().replaceFirst('Exception: ', '');

  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      await action();
      return true;
    } catch (e) {
      _error = _cleanError(e);
      return false;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  // ---------------------------------------------------------------------------
  // AKSI PUBLIK
  // ---------------------------------------------------------------------------

  Future<void> fetchQuizzes({
    String? search,
    String? status,
    int? jenjang,
  }) async {
    final requestId = ++_listRequestId;

    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      final result = await _repository.getQuizzes(
        search: search,
        status: status,
        jenjang: jenjang,
      );

      if (requestId != _listRequestId) return;
      _quizzes = result;
    } catch (e) {
      if (requestId != _listRequestId) return;
      _error = _cleanError(e);
    } finally {
      if (requestId == _listRequestId) {
        _isLoading = false;
        _safeNotify();
      }
    }
  }

  Future<void> fetchQuizById(int id) async {
    await _run(() async {
      _selectedQuiz = await _repository.getQuizById(id);
    });
  }

  Future<bool> createQuiz(Map<String, dynamic> data) {
    return _run(() async {
      final newQuiz = await _repository.createQuiz(data);
      _quizzes = [newQuiz, ..._quizzes];
    });
  }

  Future<bool> updateQuiz(int id, Map<String, dynamic> data) {
    return _run(() async {
      final updated = await _repository.updateQuiz(id, data);
      _quizzes = [
        for (final q in _quizzes) q.idQuiz == id ? updated : q,
      ];
      if (_selectedQuiz?.idQuiz == id) _selectedQuiz = updated;
    });
  }

  Future<bool> deleteQuiz(int id) async {
    try {
      await _repository.deleteQuiz(id);
      _quizzes = _quizzes.where((q) => q.idQuiz != id).toList();
      if (_selectedQuiz?.idQuiz == id) _selectedQuiz = null;
      _error = null;
      _safeNotify();
      return true;
    } catch (e) {
      _error = _cleanError(e);
      _safeNotify();
      return false;
    }
  }

  Future<bool> verifyToken(int id, String token) async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      final valid = await _repository.verifyToken(id, token);
      return valid;
    } catch (e) {
      _error = _cleanError(e);
      return false;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<QuizSubmissionResult?> submitQuiz(int id, Map<int, dynamic> answers) async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      final result = await _repository.submitQuiz(id, answers);
      await fetchQuizzes();
      return result;
    } catch (e) {
      _error = _cleanError(e);
      return null;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  void clearSelectedQuiz() {
    _selectedQuiz = null;
    _safeNotify();
  }

  void clearError() {
    _error = null;
    _safeNotify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
