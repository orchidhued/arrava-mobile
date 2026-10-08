class Module {
  final int idModul;
  final String judulModul;
  final String? fileMateri;
  final String? tipeFile;
  final int? idTipeModul;
  final int? idJenjang;
  final int? idQuiz;
  final String? progressModul;
  final String? fotoModul;

  Module({
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

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      idModul: json['id_modul'] ?? 0,
      judulModul: json['judul_modul'] ?? '',
      fileMateri: json['file_materi'],
      tipeFile: json['tipe_file'],
      idTipeModul: json['id_tipemodul'],
      idJenjang: json['id_jenjang'],
      idQuiz: json['id_quiz'],
      progressModul: json['progressModul'],
      fotoModul: json['foto_modul'],
    );
  }
}