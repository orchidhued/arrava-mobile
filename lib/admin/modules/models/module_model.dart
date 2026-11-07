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
  final int? idMapel;
  final String? namaMapel;
  final int? idQuiz;
  final String? quizJudul;
  final String? progressModul;
  final String? fotoModul;
  final String? fotoUrl;
  final int poinModul;
  final int kkmQuiz;
  final bool isVideo;
  final bool isPdf;
  final String? youtubeId;
  final String? youtubeEmbedUrl;

  // Progres belajar siswa
  final bool isMateriSelesai;
  final bool isQuizSelesai;
  final bool isQuizLulus;
  final int nilaiQuiz;
  final bool isTuntas;
  final int poinDidapat;

  // Konten catatan & soal modul mandiri
  final List<ModuleNoteModel> catatan;
  final List<ModuleQuestionModel> soalModul;

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
    this.idMapel,
    this.namaMapel,
    this.idQuiz,
    this.quizJudul,
    this.progressModul,
    this.fotoModul,
    this.fotoUrl,
    this.poinModul = 50,
    this.kkmQuiz = 70,
    this.isVideo = false,
    this.isPdf = false,
    this.youtubeId,
    this.youtubeEmbedUrl,
    this.isMateriSelesai = false,
    this.isQuizSelesai = false,
    this.isQuizLulus = false,
    this.nilaiQuiz = 0,
    this.isTuntas = false,
    this.poinDidapat = 0,
    this.catatan = const [],
    this.soalModul = const [],
  });

  bool get isDraft => progressModul?.toLowerCase() == 'draft';
  bool get hasQuizModul => soalModul.isNotEmpty;

  String? get videoPlayUrl {
    if (youtubeId != null && youtubeId!.trim().isNotEmpty) {
      return 'https://www.youtube.com/watch?v=${youtubeId!.trim()}';
    }
    if (fileUrl != null && fileUrl!.trim().isNotEmpty) {
      return fileUrl!.trim();
    }
    if (fileMateri != null && fileMateri!.trim().isNotEmpty) {
      return fileMateri!.trim();
    }
    return null;
  }

  String? get pdfDocumentUrl {
    if (fileUrl != null && fileUrl!.trim().isNotEmpty) {
      return fileUrl!.trim();
    }
    if (fileMateri != null && fileMateri!.trim().isNotEmpty) {
      return fileMateri!.trim();
    }
    return null;
  }

  ModuleModel copyWith({
    int? idModul,
    String? judulModul,
    String? fileMateri,
    String? fileUrl,
    String? tipeFile,
    int? idTipeModul,
    String? namaTipe,
    int? idJenjang,
    String? namaJenjang,
    int? idMapel,
    String? namaMapel,
    int? idQuiz,
    String? quizJudul,
    String? progressModul,
    String? fotoModul,
    String? fotoUrl,
    int? poinModul,
    int? kkmQuiz,
    bool? isVideo,
    bool? isPdf,
    String? youtubeId,
    String? youtubeEmbedUrl,
    bool? isMateriSelesai,
    bool? isQuizSelesai,
    bool? isQuizLulus,
    int? nilaiQuiz,
    bool? isTuntas,
    int? poinDidapat,
    List<ModuleNoteModel>? catatan,
    List<ModuleQuestionModel>? soalModul,
  }) {
    return ModuleModel(
      idModul: idModul ?? this.idModul,
      judulModul: judulModul ?? this.judulModul,
      fileMateri: fileMateri ?? this.fileMateri,
      fileUrl: fileUrl ?? this.fileUrl,
      tipeFile: tipeFile ?? this.tipeFile,
      idTipeModul: idTipeModul ?? this.idTipeModul,
      namaTipe: namaTipe ?? this.namaTipe,
      idJenjang: idJenjang ?? this.idJenjang,
      namaJenjang: namaJenjang ?? this.namaJenjang,
      idMapel: idMapel ?? this.idMapel,
      namaMapel: namaMapel ?? this.namaMapel,
      idQuiz: idQuiz ?? this.idQuiz,
      quizJudul: quizJudul ?? this.quizJudul,
      progressModul: progressModul ?? this.progressModul,
      fotoModul: fotoModul ?? this.fotoModul,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      poinModul: poinModul ?? this.poinModul,
      kkmQuiz: kkmQuiz ?? this.kkmQuiz,
      isVideo: isVideo ?? this.isVideo,
      isPdf: isPdf ?? this.isPdf,
      youtubeId: youtubeId ?? this.youtubeId,
      youtubeEmbedUrl: youtubeEmbedUrl ?? this.youtubeEmbedUrl,
      isMateriSelesai: isMateriSelesai ?? this.isMateriSelesai,
      isQuizSelesai: isQuizSelesai ?? this.isQuizSelesai,
      isQuizLulus: isQuizLulus ?? this.isQuizLulus,
      nilaiQuiz: nilaiQuiz ?? this.nilaiQuiz,
      isTuntas: isTuntas ?? this.isTuntas,
      poinDidapat: poinDidapat ?? this.poinDidapat,
      catatan: catatan ?? this.catatan,
      soalModul: soalModul ?? this.soalModul,
    );
  }

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    final progres = json['progres'] as Map<String, dynamic>?;
    final quiz = json['quiz'] as Map<String, dynamic>?;

    final rawCatatan = json['catatan'] as List<dynamic>? ?? [];
    final catatanList = rawCatatan
        .map((c) => ModuleNoteModel.fromJson(c as Map<String, dynamic>))
        .toList();

    final rawSoal = json['soal_modul'] as List<dynamic>? ?? [];
    final soalList = rawSoal
        .map((s) => ModuleQuestionModel.fromJson(s as Map<String, dynamic>))
        .toList();

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
      idMapel: json['id_mapel'] != null
          ? int.tryParse(json['id_mapel'].toString())
          : null,
      namaMapel: json['nama_mapel']?.toString(),
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
      kkmQuiz: json['kkm_quiz'] is int
          ? json['kkm_quiz']
          : int.tryParse(json['kkm_quiz']?.toString() ?? '70') ?? 70,
      isVideo: json['is_video'] == true ||
          json['id_tipemodul'] == 1 ||
          (json['youtube_id'] != null &&
              json['youtube_id'].toString().isNotEmpty) ||
          (json['file_materi'] != null &&
              json['file_materi'].toString().contains('youtu')),
      isPdf: json['is_pdf'] == true ||
          json['id_tipemodul'] == 2 ||
          (json['tipe_file'] != null &&
              json['tipe_file'].toString().toLowerCase() == 'pdf') ||
          (json['file_materi'] != null &&
              json['file_materi'].toString().toLowerCase().endsWith('.pdf')),
      youtubeId: json['youtube_id']?.toString() ??
          _extractYoutubeId(json['file_materi']?.toString()),
      youtubeEmbedUrl: json['youtube_embed_url']?.toString(),
      isMateriSelesai: progres?['materi_selesai'] == true,
      isQuizSelesai: progres?['quiz_selesai'] == true,
      isQuizLulus: progres?['quiz_lulus'] == true,
      nilaiQuiz: progres?['nilai_quiz'] is int
          ? progres!['nilai_quiz']
          : int.tryParse(progres?['nilai_quiz']?.toString() ?? '0') ?? 0,
      isTuntas: progres?['is_tuntas'] == true,
      poinDidapat: progres?['poin_didapat'] is int
          ? progres!['poin_didapat']
          : int.tryParse(progres?['poin_didapat']?.toString() ?? '0') ?? 0,
      catatan: catatanList,
      soalModul: soalList,
    );
  }

  static String? _extractYoutubeId(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final regExp = RegExp(
      r'(?:youtu\.be\/|youtube(?:-nocookie)?\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))([\w-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    if (url.trim().length == 11 && !url.contains('/')) {
      return url.trim();
    }
    return null;
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
      'id_mapel': idMapel,
      'nama_mapel': namaMapel,
      'id_quiz': idQuiz,
      'progressModul': progressModul,
      'foto_modul': fotoModul,
      'foto_url': fotoUrl,
      'poin_modul': poinModul,
      'kkm_quiz': kkmQuiz,
      'is_video': isVideo,
      'is_pdf': isPdf,
      'youtube_id': youtubeId,
    };
  }
}

class ModuleNoteModel {
  final int idCatatan;
  final String judul;
  final String isi;
  final int urutan;

  ModuleNoteModel({
    required this.idCatatan,
    required this.judul,
    required this.isi,
    this.urutan = 0,
  });

  factory ModuleNoteModel.fromJson(Map<String, dynamic> json) {
    return ModuleNoteModel(
      idCatatan: json['id_catatan'] is int
          ? json['id_catatan']
          : int.tryParse(json['id_catatan']?.toString() ?? '0') ?? 0,
      judul: json['judul']?.toString() ?? '',
      isi: json['isi']?.toString() ?? '',
      urutan: json['urutan'] is int
          ? json['urutan']
          : int.tryParse(json['urutan']?.toString() ?? '0') ?? 0,
    );
  }
}

class ModuleQuestionModel {
  final int idSoal;
  final String pertanyaan;
  final int poin;
  final int urutan;
  final List<ModuleOptionModel> pilihan;

  ModuleQuestionModel({
    required this.idSoal,
    required this.pertanyaan,
    this.poin = 10,
    this.urutan = 0,
    this.pilihan = const [],
  });

  factory ModuleQuestionModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['pilihan'] as List<dynamic>? ?? [];
    return ModuleQuestionModel(
      idSoal: json['id_soal'] is int
          ? json['id_soal']
          : int.tryParse(json['id_soal']?.toString() ?? '0') ?? 0,
      pertanyaan: json['pertanyaan']?.toString() ?? '',
      poin: json['poin'] is int
          ? json['poin']
          : int.tryParse(json['poin']?.toString() ?? '10') ?? 10,
      urutan: json['urutan'] is int
          ? json['urutan']
          : int.tryParse(json['urutan']?.toString() ?? '0') ?? 0,
      pilihan: rawOptions
          .map((opt) => ModuleOptionModel.fromJson(opt as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ModuleOptionModel {
  final int idPilihan;
  final String label;
  final String teksPilihan;

  ModuleOptionModel({
    required this.idPilihan,
    required this.label,
    required this.teksPilihan,
  });

  factory ModuleOptionModel.fromJson(Map<String, dynamic> json) {
    return ModuleOptionModel(
      idPilihan: json['id_pilihan'] is int
          ? json['id_pilihan']
          : int.tryParse(json['id_pilihan']?.toString() ?? '0') ?? 0,
      label: json['label']?.toString() ?? '',
      teksPilihan: json['teks_pilihan']?.toString() ?? '',
    );
  }
}

class ModuleQuizSubmitResult {
  final bool success;
  final int benar;
  final int totalSoal;
  final int skor;
  final int kkm;
  final bool isLulus;
  final bool isTuntas;
  final bool materiSelesai;
  final int poinDiberikan;

  ModuleQuizSubmitResult({
    required this.success,
    required this.benar,
    required this.totalSoal,
    required this.skor,
    required this.kkm,
    required this.isLulus,
    required this.isTuntas,
    required this.materiSelesai,
    required this.poinDiberikan,
  });

  factory ModuleQuizSubmitResult.fromJson(Map<String, dynamic> json) {
    return ModuleQuizSubmitResult(
      success: json['success'] == true,
      benar: json['benar'] is int
          ? json['benar']
          : int.tryParse(json['benar']?.toString() ?? '0') ?? 0,
      totalSoal: json['total_soal'] is int
          ? json['total_soal']
          : int.tryParse(json['total_soal']?.toString() ?? '0') ?? 0,
      skor: json['skor'] is int
          ? json['skor']
          : int.tryParse(json['skor']?.toString() ?? '0') ?? 0,
      kkm: json['kkm'] is int
          ? json['kkm']
          : int.tryParse(json['kkm']?.toString() ?? '70') ?? 70,
      isLulus: json['is_lulus'] == true,
      isTuntas: json['is_tuntas'] == true,
      materiSelesai: json['materi_selesai'] == true,
      poinDiberikan: json['poin_diberikan'] is int
          ? json['poin_diberikan']
          : int.tryParse(json['poin_diberikan']?.toString() ?? '0') ?? 0,
    );
  }
}
