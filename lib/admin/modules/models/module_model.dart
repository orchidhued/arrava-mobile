class ModuleModel {
  final int idModul;
  final String judulModul;
  final String? fileMateri;
  final String? fileUrl;
  final String? tipeFile;
  final int? idTipeModul;
  final String? namaTipe;
  final int? idJenjang;
  final String? namaJenjang;
  final int? idQuiz;
  final String? quizJudul;
  final String? progressModul;
  final String? fotoModul;
  final String? fotoUrl;
  final int poinModul;
  final bool isVideo;
  final bool isPdf;
  final String? youtubeId;
  final String? youtubeEmbedUrl;
  final bool isMateriSelesai;
  final bool isTuntas;

  ModuleModel({
    required this.idModul,
    required this.judulModul,
    this.fileMateri,
    this.fileUrl,
    this.tipeFile,
    this.idTipeModul,
    this.namaTipe,
    this.idJenjang,
    this.namaJenjang,
    this.idQuiz,
    this.quizJudul,
    this.progressModul,
    this.fotoModul,
    this.fotoUrl,
    this.poinModul = 50,
    this.isVideo = false,
    this.isPdf = false,
    this.youtubeId,
    this.youtubeEmbedUrl,
    this.isMateriSelesai = false,
    this.isTuntas = false,
  });

  bool get isDraft => progressModul?.toLowerCase() == 'draft';

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    final progres = json['progres'] as Map<String, dynamic>?;
    final quiz = json['quiz'] as Map<String, dynamic>?;

    return ModuleModel(
      idModul: json['id_modul'] is int
          ? json['id_modul']
          : int.tryParse(json['id_modul']?.toString() ?? '0') ?? 0,
      judulModul: json['judul_modul']?.toString() ?? '',
      fileMateri: json['file_materi']?.toString(),
      fileUrl: json['file_url']?.toString(),
      tipeFile: json['tipe_file']?.toString(),
      idTipeModul: json['id_tipemodul'] != null
          ? int.tryParse(json['id_tipemodul'].toString())
          : null,
      namaTipe: json['nama_tipe']?.toString(),
      idJenjang: json['id_jenjang'] != null
          ? int.tryParse(json['id_jenjang'].toString())
          : null,
      namaJenjang: json['nama_jenjang']?.toString(),
      idQuiz: json['id_quiz'] != null
          ? int.tryParse(json['id_quiz'].toString())
          : null,
      quizJudul: quiz?['judul']?.toString(),
      progressModul: json['progressModul']?.toString(),
      fotoModul: json['foto_modul']?.toString(),
      fotoUrl: json['foto_url']?.toString(),
      poinModul: json['poin_modul'] is int
          ? json['poin_modul']
          : int.tryParse(json['poin_modul']?.toString() ?? '50') ?? 50,
      isVideo: json['is_video'] == true,
      isPdf: json['is_pdf'] == true,
      youtubeId: json['youtube_id']?.toString(),
      youtubeEmbedUrl: json['youtube_embed_url']?.toString(),
      isMateriSelesai: progres?['materi_selesai'] == true,
      isTuntas: progres?['is_tuntas'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_modul': idModul,
      'judul_modul': judulModul,
      'file_materi': fileMateri,
      'file_url': fileUrl,
      'tipe_file': tipeFile,
      'id_tipemodul': idTipeModul,
      'nama_tipe': namaTipe,
      'id_jenjang': idJenjang,
      'nama_jenjang': namaJenjang,
      'id_quiz': idQuiz,
      'progressModul': progressModul,
      'foto_modul': fotoModul,
      'foto_url': fotoUrl,
      'poin_modul': poinModul,
      'is_video': isVideo,
      'is_pdf': isPdf,
      'youtube_id': youtubeId,
    };
  }
}
