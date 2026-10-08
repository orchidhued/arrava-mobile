class ModuleModel {
  final int idModul;
  final String judulModul;
  final String? fileMateri;
  final String? tipeFile;
  final int? idTipeModul;
  final int? idJenjang;
  final int? idQuiz;
  final String? progressModul;
  final String? fotoModul;

  ModuleModel({
    required this.idModul,
    required this.judulModul,
    this.fileMateri,
    this.tipeFile,
    this.idTipeModul,
    this.idJenjang,
    this.idQuiz,
    this.progressModul,
    this.fotoModul,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      idModul: json['id_modul'] ?? 0,
      judulModul: json['judul_modul'] ?? '',
      fileMateri: json['file_materi']?.toString(),
      tipeFile: json['tipe_file']?.toString(),
      idTipeModul: json['id_tipemodul'] != null ? int.tryParse(json['id_tipemodul'].toString()) : null,
      idJenjang: json['id_jenjang'] != null ? int.tryParse(json['id_jenjang'].toString()) : null,
      idQuiz: json['id_quiz'] != null ? int.tryParse(json['id_quiz'].toString()) : null,
      progressModul: json['progressModul']?.toString(),
      fotoModul: json['foto_modul']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_modul': idModul,
      'judul_modul': judulModul,
      'file_materi': fileMateri,
      'tipe_file': tipeFile,
      'id_tipemodul': idTipeModul,
      'id_jenjang': idJenjang,
      'id_quiz': idQuiz,
      'progressModul': progressModul,
      'foto_modul': fotoModul,
    };
  }
}
