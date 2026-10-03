import 'package:flutter/foundation.dart';
import '../models/module_model.dart';
import '../repositories/module_repository.dart';

class ModuleProvider with ChangeNotifier {
  final ModuleRepository _repository;

  ModuleProvider({ModuleRepository? repository}) : _repository = repository ?? ModuleRepository();

  List<ModuleModel> _modules = [];
  List<ModuleModel> get modules => _modules;

  ModuleModel? _selectedModule;
  ModuleModel? get selectedModule => _selectedModule;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchModules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _modules = await _repository.getModules();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchModuleById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedModule = await _repository.getModuleById(id);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createModule(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newModule = await _repository.createModule(data);
      _modules.add(newModule);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateModule(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedModule = await _repository.updateModule(id, data);
      final index = _modules.indexWhere((m) => m.idModul == id);
      if (index != -1) {
        _modules[index] = updatedModule;
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteModule(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteModule(id);
      _modules.removeWhere((m) => m.idModul == id);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
