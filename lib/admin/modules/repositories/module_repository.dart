import '../models/module_model.dart';
import '../services/module_service.dart';

class ModuleRepository {
  final ModuleService _service;

  ModuleRepository({ModuleService? service}) : _service = service ?? ModuleService();

  Future<List<ModuleModel>> getModules({
    String? search,
    String? status,
    int? jenjang,
    int? mapel,
  }) async {
    final response = await _service.fetchModules(
      search: search,
      status: status,
      jenjang: jenjang,
      mapel: mapel,
    );
    final data = response['data'] as List?;
    if (data == null) return [];
    return data.map((e) => ModuleModel.fromJson(e)).toList();
  }

  Future<ModuleModel> getModuleById(int id) async {
    final response = await _service.fetchModuleById(id);
    return ModuleModel.fromJson(response['data']);
  }

  Future<Map<String, dynamic>> completeModule(int id) async {
    final response = await _service.completeModule(id);
    return response as Map<String, dynamic>;
  }

  Future<ModuleQuizSubmitResult> submitModuleQuiz(int id, Map<int, int> answers) async {
    final response = await _service.submitModuleQuiz(id, answers);
    return ModuleQuizSubmitResult.fromJson(response as Map<String, dynamic>);
  }

  Future<ModuleModel> createModule(Map<String, dynamic> data) async {
    final response = await _service.createModule(data);
    return ModuleModel.fromJson(response['data']);
  }

  Future<ModuleModel> updateModule(int id, Map<String, dynamic> data) async {
    final response = await _service.updateModule(id, data);
    return ModuleModel.fromJson(response['data']);
  }

  Future<void> deleteModule(int id) async {
    await _service.deleteModule(id);
  }
}
