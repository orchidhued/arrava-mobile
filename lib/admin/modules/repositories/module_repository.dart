import '../models/module_model.dart';
import '../services/module_service.dart';

class ModuleRepository {
  final ModuleService _service;

  ModuleRepository({ModuleService? service}) : _service = service ?? ModuleService();

  Future<List<ModuleModel>> getModules() async {
    final response = await _service.fetchModules();
    final data = response['data'] as List?;
    if (data == null) return [];
    return data.map((e) => ModuleModel.fromJson(e)).toList();
  }

  Future<ModuleModel> getModuleById(int id) async {
    final response = await _service.fetchModuleById(id);
    return ModuleModel.fromJson(response['data']);
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
