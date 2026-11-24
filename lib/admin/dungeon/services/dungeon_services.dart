import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';

class DungeonService {
  /// 1. Mengambil daftar mapel dungeon dan statusnya (terbuka / terkunci, rekor, lantai tertinggi)
  static Future<List<Map<String, dynamic>>> fetchDungeonList() async {
    final response = await ApiClient.get(ApiConstants.dungeon);
    if (response is Map &&
        response['success'] == true &&
        response['dungeons'] is List) {
      return List<Map<String, dynamic>>.from(response['dungeons']);
    }
    return [];
  }

  /// 2. Memulai petualangan baru di lantai 1 aFtau resume sesi yang sedang berjalan
  static Future<Map<String, dynamic>> mulaiPetualangan(int idMapel) async {
    final response = await ApiClient.post(
      '${ApiConstants.dungeon}/$idMapel/mulai',
    );
    if (response is Map && response['success'] == true) {
      return Map<String, dynamic>.from(response);
    }
    throw Exception(response['message'] ?? 'Gagal memulai petualangan Dungeon');
  }

  /// 3. Mengirimkan jawaban siswa
  /// [jawaban] berupa id_pilihan (angka) untuk Pilihan Ganda, atau string teks untuk Isian Singkat
  static Future<Map<String, dynamic>> jawabSoal({
    required int idMapel,
    required int idSoal,
    required dynamic jawaban,
  }) async {
    final response = await ApiClient.post(
      '${ApiConstants.dungeon}/$idMapel/jawab',
      body: {'id_soal': idSoal, 'jawaban': jawaban},
    );
    if (response is Map && response['success'] == true) {
      return Map<String, dynamic>.from(response['hasil']);
    }
    throw Exception(response['message'] ?? 'Gagal mengirim jawaban');
  }

  /// 4. Menyerah / Mengakhiri petualangan (klaim poin lantai saat ini)
  static Future<Map<String, dynamic>> selesaiPetualangan(int idMapel) async {
    final response = await ApiClient.post(
      '${ApiConstants.dungeon}/$idMapel/selesai',
    );
    if (response is Map && response['success'] == true) {
      return Map<String, dynamic>.from(response);
    }
    throw Exception(response['message'] ?? 'Gagal mengakhiri petualangan');
  }

  /// 5. Mengambil riwayat petualangan dungeon siswa
  static Future<Map<String, dynamic>> fetchRiwayat() async {
    final response = await ApiClient.get(ApiConstants.dungeonRiwayat);
    if (response is Map && response['success'] == true) {
      return Map<String, dynamic>.from(response['riwayat']);
    }
    return {};
  }
}
