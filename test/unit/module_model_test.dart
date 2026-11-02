import 'package:flutter_test/flutter_test.dart';
import 'package:arrava_mobile/admin/modules/models/module_model.dart';

void main() {
  group('ModuleModel Unit Tests', () {
    test('ModuleModel.fromJson should parse valid JSON correctly', () {
      final json = {
        'id_modul': 10,
        'judul_modul': 'Belajar Matematika',
        'file_materi': 'materi.pdf',
        'tipe_file': 'pdf',
        'id_tipemodul': '2',
        'id_jenjang': '1',
        'progressModul': 'Tersedia',
      };

      final model = ModuleModel.fromJson(json);

      expect(model.idModul, 10);
      expect(model.judulModul, 'Belajar Matematika');
      expect(model.fileMateri, 'materi.pdf');
      expect(model.tipeFile, 'pdf');
      expect(model.idTipeModul, 2);
      expect(model.idJenjang, 1);
      expect(model.progressModul, 'Tersedia');
    });

    test('ModuleModel.fromJson should handle null and default values safely', () {
      final json = <String, dynamic>{};

      final model = ModuleModel.fromJson(json);

      expect(model.idModul, 0);
      expect(model.judulModul, '');
      expect(model.fileMateri, isNull);
      expect(model.idJenjang, isNull);
    });

    test('ModuleModel.toJson should serialize fields accurately', () {
      final model = ModuleModel(
        idModul: 5,
        judulModul: 'Fisika Dasar',
        fileMateri: 'fisika.pdf',
        tipeFile: 'pdf',
        idTipeModul: 1,
        idJenjang: 3,
        progressModul: 'Draft',
      );

      final json = model.toJson();

      expect(json['id_modul'], 5);
      expect(json['judul_modul'], 'Fisika Dasar');
      expect(json['file_materi'], 'fisika.pdf');
      expect(json['progressModul'], 'Draft');
    });
  });
}

