import '../models/quiz_model.dart';
import '../services/quiz_service.dart';

class QuizRepository {
  final QuizService _service;

  QuizRepository({QuizService? service}) : _service = service ?? QuizService();

  Future<List<QuizModel>> getQuizzes({
    String? search,
    String? status,
    int? jenjang,
    int? mapel,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (jenjang != null) queryParams['jenjang'] = jenjang.toString();
    if (mapel != null) queryParams['mapel'] = mapel.toString();

    final response = await _service.fetchQuizzes(queryParams: queryParams);
    final data = response['data'] as List?;
    if (data == null) return [];
    return data.map((e) => QuizModel.fromJson(e)).toList();
  }

  Future<List<MapelModel>> getMapels({int? jenjang}) async {
    final queryParams = <String, String>{};
    if (jenjang != null) queryParams['jenjang'] = jenjang.toString();
    return await _service.fetchMapelModels(queryParams: queryParams);
  }

  Future<QuizModel> getQuizById(int id) async {
    final response = await _service.fetchQuizById(id);
    return QuizModel.fromJson(response['data']);
  }

  Future<QuizModel> createQuiz(Map<String, dynamic> data) async {
    final response = await _service.createQuiz(data);
    return QuizModel.fromJson(response['data']);
  }

  Future<QuizModel> updateQuiz(int id, Map<String, dynamic> data) async {
    final response = await _service.updateQuiz(id, data);
    return QuizModel.fromJson(response['data']);
  }

  Future<void> deleteQuiz(int id) async {
    await _service.deleteQuiz(id);
  }

  Future<bool> verifyToken(int id, String token) async {
    final response = await _service.verifyToken(id, token);
    return response['data']?['valid'] == true;
  }

  Future<QuizSubmissionResult> submitQuiz(int id, Map<int, dynamic> answers) async {
    final response = await _service.submitQuiz(id, answers);
    return QuizSubmissionResult.fromJson(response['data']);
  }
}
