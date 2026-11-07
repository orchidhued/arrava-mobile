import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

class ModuleService {
  Future<dynamic> fetchModules({
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

    String endpoint = ApiConstants.modules;
    if (queryParams.isNotEmpty) {
      final queryString = Uri(queryParameters: queryParams).query;
      endpoint = '$endpoint?$queryString';
    }

    return await ApiClient.get(endpoint);
  }

  Future<dynamic> fetchModuleById(int id) async {
    return await ApiClient.get('${ApiConstants.modules}/$id');
  }

  Future<dynamic> completeModule(int id) async {
    return await ApiClient.post('${ApiConstants.modules}/$id/complete');
  }

  Future<dynamic> submitModuleQuiz(int id, Map<int, int> answers) async {
    final formattedAnswers = answers.map((key, value) => MapEntry(key.toString(), value));
    return await ApiClient.post(
      '${ApiConstants.modules}/$id/quiz-submit',
      body: {'jawaban': formattedAnswers},
    );
  }

  Future<dynamic> createModule(Map<String, dynamic> data) async {
    return await ApiClient.post(ApiConstants.modules, body: data);
  }

  Future<dynamic> updateModule(int id, Map<String, dynamic> data) async {
    return await ApiClient.put('${ApiConstants.modules}/$id', body: data);
  }

  Future<dynamic> deleteModule(int id) async {
    return await ApiClient.delete('${ApiConstants.modules}/$id');
  }
}
