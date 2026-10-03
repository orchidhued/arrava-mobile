import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

class ModuleService {
  Future<dynamic> fetchModules() async {
    return await ApiClient.get(ApiConstants.modules);
  }

  Future<dynamic> fetchModuleById(int id) async {
    return await ApiClient.get('${ApiConstants.modules}/$id');
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
