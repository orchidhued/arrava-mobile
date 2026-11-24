// =============================================================================
// quiz_service.dart
// -----------------------------------------------------------------------------
// Lapisan akses API untuk fitur Quiz.
// =============================================================================

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/quiz_model.dart';

class QuizService {
  String _withQuery(String endpoint, Map<String, String?> params) {
    final clean = <String, String>{
      for (final e in params.entries)
        if (e.value != null && e.value!.isNotEmpty) e.key: e.value!,
    };
    if (clean.isEmpty) return endpoint;
    return '$endpoint?${Uri(queryParameters: clean).query}';
  }

  dynamic _unwrap(dynamic response) {
    if (response is Map && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  List _extractList(dynamic response) {
    var data = _unwrap(response);
    if (data is Map && data.containsKey('data')) data = data['data'];
    return data is List ? data : const [];
  }

  // ---------------------------------------------------------------------------
  // QUIZ - REST API
  // ---------------------------------------------------------------------------

  Future<dynamic> fetchQuizzes({Map<String, String>? queryParams}) async {
    final endpoint = _withQuery(ApiConstants.quizzes, queryParams ?? {});
    return await ApiClient.get(endpoint);
  }

  Future<dynamic> fetchQuizById(int id) async {
    return await ApiClient.get('${ApiConstants.quizzes}/$id');
  }

  Future<dynamic> createQuiz(Map<String, dynamic> data) async {
    return await ApiClient.post(ApiConstants.quizzes, body: data);
  }

  Future<dynamic> updateQuiz(int id, Map<String, dynamic> data) async {
    return await ApiClient.put('${ApiConstants.quizzes}/$id', body: data);
  }

  Future<dynamic> deleteQuiz(int id) async {
    return await ApiClient.delete('${ApiConstants.quizzes}/$id');
  }

  Future<dynamic> verifyToken(int id, String token) async {
    return await ApiClient.post(
      '${ApiConstants.quizzes}/$id/verify-token',
      body: {'token': token},
    );
  }

  Future<dynamic> submitQuiz(int id, Map<int, dynamic> answers) async {
    final list = answers.entries.map((e) => {
      'id_soal': e.key,
      'jawaban': e.value,
    }).toList();

    return await ApiClient.post(
      '${ApiConstants.quizzes}/$id/submit',
      body: {'jawaban': list},
    );
  }

  // ---------------------------------------------------------------------------
  // QUIZ - BERTYPE (QuizModel)
  // ---------------------------------------------------------------------------

  Future<List<QuizModel>> fetchQuizModels({
    Map<String, String>? queryParams,
  }) async {
    final response = await fetchQuizzes(queryParams: queryParams);
    return _extractList(response)
        .whereType<Map>()
        .map((e) => QuizModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<QuizModel> fetchQuizModelById(int id) async {
    final data = _unwrap(await fetchQuizById(id));
    if (data is! Map) {
      throw const FormatException('Format detail quiz tidak valid');
    }
    return QuizModel.fromJson(Map<String, dynamic>.from(data));
  }

  // ---------------------------------------------------------------------------
  // MATA PELAJARAN (MAPEL)
  // ---------------------------------------------------------------------------

  Future<dynamic> fetchMapel({Map<String, String>? queryParams}) async {
    final endpoint = _withQuery(ApiConstants.mapel, queryParams ?? {});
    return await ApiClient.get(endpoint);
  }

  Future<List<MapelModel>> fetchMapels() => fetchMapelModels();

  Future<List<MapelModel>> fetchMapelModels({
    Map<String, String>? queryParams,
  }) async {
    final response = await fetchMapel(queryParams: queryParams);
    return _extractList(response)
        .whereType<Map>()
        .map((e) => MapelModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // TINGKAT KELAS
  // ---------------------------------------------------------------------------

  Future<dynamic> fetchTingkatKelasRaw({int? jenjang}) async {
    final endpoint = jenjang != null
        ? ApiConstants.tingkatKelasByJenjang(jenjang)
        : ApiConstants.tingkatKelas;
    return await ApiClient.get(endpoint);
  }

  Future<List<TingkatKelasModel>> fetchTingkatKelasModels({int? jenjang}) async {
    final response = await fetchTingkatKelasRaw(jenjang: jenjang);
    return _extractList(response)
        .whereType<Map>()
        .map((e) => TingkatKelasModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // BANK SOAL
  // ---------------------------------------------------------------------------

  Future<dynamic> fetchQuestionBank({int page = 1, String? search}) async {
    final endpoint = _withQuery('${ApiConstants.quizzes}/questions/bank', {
      'page': page.toString(),
      'search': search?.trim(),
    });
    return await ApiClient.get(endpoint);
  }

  Future<List<QuestionModel>> fetchQuestionBankModels({
    int page = 1,
    String? search,
  }) async {
    return fetchBankSoalList(search: search);
  }

  Future<List<QuestionModel>> fetchBankSoalList({
    String sumber = 'all',
    int? mapelId,
    int? jenjangId,
    String? jenisSoal,
    String? tingkatSoal,
    String? search,
    int limit = 150,
  }) async {
    final query = <String, String>{
      'sumber': sumber,
      'limit': limit.toString(),
    };
    if (mapelId != null) query['mapel_id'] = mapelId.toString();
    if (jenjangId != null) query['jenjang_id'] = jenjangId.toString();
    if (jenisSoal != null && jenisSoal != 'all') query['jenis_soal'] = jenisSoal;
    if (tingkatSoal != null && tingkatSoal != 'all') query['tingkat_soal'] = tingkatSoal;
    if (search != null && search.trim().isNotEmpty) query['q'] = search.trim();

    final endpoint = _withQuery(ApiConstants.bankSoalData, query);
    final response = await ApiClient.get(endpoint);
    return _extractList(response)
        .whereType<Map>()
        .map((e) => QuestionModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>> copySoalToBank(List<int> soalIds) async {
    final response = await ApiClient.post(
      ApiConstants.copyToBank,
      body: {'soal_ids': soalIds},
    );
    return (response is Map) ? Map<String, dynamic>.from(response) : {};
  }

  Future<Map<String, dynamic>> assignSoalToQuiz(int idQuiz, List<int> soalIds) async {
    final response = await ApiClient.post(
      ApiConstants.assignToQuiz,
      body: {
        'id_quiz': idQuiz,
        'soal_ids': soalIds,
      },
    );
    return (response is Map) ? Map<String, dynamic>.from(response) : {};
  }

  Future<void> deleteSoal(int idSoal) async {
    await ApiClient.delete(ApiConstants.deleteSoal(idSoal));
  }
}
