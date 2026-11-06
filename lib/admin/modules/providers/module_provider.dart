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

  Future<void> fetchModules({
    String? search,
    String? status,
    int? jenjang,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _modules = await _repository.getModules(
        search: search,
        status: status,
        jenjang: jenjang,
      );
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

  Future<bool> completeModule(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.completeModule(id);
      final isTuntas = response['is_tuntas'] == true;
      final poinDiberikan = response['poin_diberikan'] is int
          ? response['poin_diberikan']
          : int.tryParse(response['poin_diberikan']?.toString() ?? '0') ?? 0;

      final index = _modules.indexWhere((m) => m.idModul == id);
      if (index != -1) {
        final old = _modules[index];
        _modules[index] = old.copyWith(
          isMateriSelesai: true,
          isTuntas: isTuntas,
          poinDidapat: old.poinDidapat + (poinDiberikan as int),
        );
      }
      if (_selectedModule != null && _selectedModule!.idModul == id) {
        _selectedModule = _selectedModule!.copyWith(
          isMateriSelesai: true,
          isTuntas: isTuntas,
          poinDidapat: _selectedModule!.poinDidapat + (poinDiberikan as int),
        );
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

  Future<ModuleQuizSubmitResult?> submitModuleQuiz(
      int id, Map<int, int> answers) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.submitModuleQuiz(id, answers);

      final index = _modules.indexWhere((m) => m.idModul == id);
      if (index != -1) {
        final old = _modules[index];
        _modules[index] = old.copyWith(
          isQuizSelesai: true,
          isQuizLulus: result.isLulus,
          nilaiQuiz:
              result.skor > old.nilaiQuiz ? result.skor : old.nilaiQuiz,
          isTuntas: result.isTuntas,
          poinDidapat: old.poinDidapat + result.poinDiberikan,
        );
      }
      if (_selectedModule != null && _selectedModule!.idModul == id) {
        _selectedModule = _selectedModule!.copyWith(
          isQuizSelesai: true,
          isQuizLulus: result.isLulus,
          nilaiQuiz: result.skor > _selectedModule!.nilaiQuiz
              ? result.skor
              : _selectedModule!.nilaiQuiz,
          isTuntas: result.isTuntas,
          poinDidapat: _selectedModule!.poinDidapat + result.poinDiberikan,
        );
      }
      return result;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return null;
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
      final updated = await _repository.updateModule(id, data);
      final index = _modules.indexWhere((m) => m.idModul == id);
      if (index != -1) {
        _modules[index] = updated;
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
