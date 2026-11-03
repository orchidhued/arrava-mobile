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

    test('ModuleModel.fromJson should parse enriched video and progress fields', () {
      final json = {
        'id_modul': 12,
        'judul_modul': 'Video Gravitasi Fisika',
        'file_materi': 'https://youtube.com/watch?v=abcdefghijk',
        'file_url': 'https://youtube.com/watch?v=abcdefghijk',
        'tipe_file': 'video',
        'id_tipemodul': 1,
        'nama_tipe': 'Video',
        'id_jenjang': 3,
        'nama_jenjang': 'SMA',
        'id_quiz': 7,
        'quiz': {
          'id_quiz': 7,
          'judul': 'Kuis Fisika Gravitasi',
        },
        'progressModul': 'Published',
        'foto_url': 'http://127.0.0.1:8000/storage/covers/sample.jpg',
        'poin_modul': 60,
        'is_video': true,
        'is_pdf': false,
        'youtube_id': 'abcdefghijk',
        'progres': {
          'materi_selesai': true,
          'quiz_selesai': false,
          'quiz_lulus': false,
          'is_tuntas': false,
          'poin_didapat': 0,
        },
      };

      final model = ModuleModel.fromJson(json);

      expect(model.idModul, 12);
      expect(model.judulModul, 'Video Gravitasi Fisika');
      expect(model.isVideo, isTrue);
      expect(model.isPdf, isFalse);
      expect(model.youtubeId, 'abcdefghijk');
      expect(model.quizJudul, 'Kuis Fisika Gravitasi');
      expect(model.isMateriSelesai, isTrue);
      expect(model.isTuntas, isFalse);
      expect(model.poinModul, 60);
    });

    test('ModuleModel.fromJson should handle null and default values safely', () {
      final json = <String, dynamic>{};

      final model = ModuleModel.fromJson(json);

      expect(model.idModul, 0);
      expect(model.judulModul, '');
      expect(model.fileMateri, isNull);
      expect(model.idJenjang, isNull);
      expect(model.isMateriSelesai, isFalse);
      expect(model.isTuntas, isFalse);
      expect(model.isVideo, isFalse);
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
