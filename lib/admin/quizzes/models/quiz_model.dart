// =============================================================================
// quiz_models.dart
// -----------------------------------------------------------------------------
// Model data untuk fitur Quiz (Sinkron dengan Database & Backend Laravel).
//
// Hierarki data:
//   QuizModel
//    ├── soal        : List<QuestionModel>
//    │      └── pilihan : List<OptionModel>
//    └── userResult  : QuizUserResult? (hasil pengerjaan siswa yang sedang login)
// =============================================================================

/// Mengubah nilai dinamis menjadi int?. Mengembalikan null jika gagal/kosong.
int? _toIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

/// Mengubah nilai dinamis menjadi int, dengan nilai cadangan [fallback].
int _toInt(dynamic value, {int fallback = 0}) {
  return _toIntOrNull(value) ?? fallback;
}

/// Mengubah nilai dinamis menjadi bool.
bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value == 1;
  if (value is String) {
    final v = value.toLowerCase();
    return v == '1' || v == 'true';
  }
  return false;
}

/// Mengubah nilai dinamis menjadi String?, null tetap null.
String? _toStringOrNull(dynamic value) => value?.toString();

/// Memetakan list JSON menjadi list objek dengan aman.
List<T> _parseList<T>(dynamic raw, T Function(Map<String, dynamic>) builder) {
  if (raw is! List) return [];
  return raw
      .whereType<Map>()
      .map((e) => builder(Map<String, dynamic>.from(e)))
      .toList();
}

// -----------------------------------------------------------------------------
// ENUM JENIS SOAL
// -----------------------------------------------------------------------------
enum JenisSoal {
  kuis,
  trueFalse,
  isianSingkat;

  String get apiValue {
    switch (this) {
      case JenisSoal.kuis:
        return 'kuis';
      case JenisSoal.trueFalse:
        return 'true_false';
      case JenisSoal.isianSingkat:
        return 'isian_singkat';
    }
  }

  static JenisSoal fromApi(String? value) {
    switch (value) {
      case 'true_false':
        return JenisSoal.trueFalse;
      case 'isian_singkat':
        return JenisSoal.isianSingkat;
      case 'kuis':
      default:
        return JenisSoal.kuis;
    }
  }
}

// =============================================================================
// OPTION MODEL - satu pilihan jawaban
// =============================================================================
class OptionModel {
  final int? idPilihan;
  final String label;
  final String teksPilihan;
  final bool isCorrect;

  const OptionModel({
    this.idPilihan,
    required this.label,
    required this.teksPilihan,
    required this.isCorrect,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      idPilihan: _toIntOrNull(json['id_pilihan']),
      label: json['label']?.toString() ?? '',
      teksPilihan: json['teks_pilihan']?.toString() ?? '',
      isCorrect: _toBool(json['is_correct']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idPilihan != null) 'id_pilihan': idPilihan,
      'label': label,
      'teks_pilihan': teksPilihan,
      'is_correct': isCorrect,
    };
  }

  OptionModel copyWith({
    int? idPilihan,
    String? label,
    String? teksPilihan,
    bool? isCorrect,
  }) {
    return OptionModel(
      idPilihan: idPilihan ?? this.idPilihan,
      label: label ?? this.label,
      teksPilihan: teksPilihan ?? this.teksPilihan,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}

// =============================================================================
// QUESTION MODEL - satu butir soal
// =============================================================================
class QuestionModel {
  final int? idSoal;
  final String? kodeSoal;
  final String pertanyaan;
  final int? idJenisSoal;
  final JenisSoal jenisSoal;
  final String? jawabanBenar;
  final int poin;
  final int durasiDetik;
  final String? fotoSoal;
  final List<OptionModel> pilihan;

  const QuestionModel({
    this.idSoal,
    this.kodeSoal,
    required this.pertanyaan,
    this.idJenisSoal,
    this.jenisSoal = JenisSoal.kuis,
    this.jawabanBenar,
    this.poin = 10,
    this.durasiDetik = 20,
    this.fotoSoal,
    this.pilihan = const [],
  });

  int get correctAnswerIndex {
    return pilihan.indexWhere((p) => p.isCorrect);
  }

  OptionModel? get correctOption {
    final idx = correctAnswerIndex;
    return idx >= 0 ? pilihan[idx] : null;
  }

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final jenisStr = json['jenis_soal']?.toString();
    final idJenis = _toIntOrNull(json['id_jenis_soal']);

    JenisSoal jenis;
    if (jenisStr != null) {
      jenis = JenisSoal.fromApi(jenisStr);
    } else if (idJenis == 3) {
      jenis = JenisSoal.trueFalse;
    } else if (idJenis == 2) {
      jenis = JenisSoal.isianSingkat;
    } else {
      jenis = JenisSoal.kuis;
    }

    return QuestionModel(
      idSoal: _toIntOrNull(json['id_soal']),
      kodeSoal: _toStringOrNull(json['kode_soal']),
      pertanyaan: json['pertanyaan']?.toString() ?? '',
      idJenisSoal: idJenis,
      jenisSoal: jenis,
      jawabanBenar: _toStringOrNull(json['jawaban_benar']),
      poin: _toInt(json['poin'], fallback: 10),
      durasiDetik: _toInt(json['durasi_detik'], fallback: 20),
      fotoSoal: _toStringOrNull(json['foto_soal']),
      pilihan: _parseList(json['pilihan'], OptionModel.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idSoal != null) 'id_soal': idSoal,
      if (kodeSoal != null) 'kode_soal': kodeSoal,
      'pertanyaan': pertanyaan,
      'id_jenis_soal': idJenisSoal ?? (jenisSoal == JenisSoal.trueFalse ? 3 : (jenisSoal == JenisSoal.isianSingkat ? 2 : 1)),
      'jenis_soal': jenisSoal.apiValue,
      'jawaban_benar': jawabanBenar ?? (correctOption?.label ?? 'A'),
      'poin': poin,
      'durasi_detik': durasiDetik,
      'pilihan': pilihan.map((e) => e.toJson()).toList(),
    };
  }

  QuestionModel copyWith({
    int? idSoal,
    String? kodeSoal,
    String? pertanyaan,
    int? idJenisSoal,
    JenisSoal? jenisSoal,
    String? jawabanBenar,
    int? poin,
    int? durasiDetik,
    String? fotoSoal,
    List<OptionModel>? pilihan,
  }) {
    return QuestionModel(
      idSoal: idSoal ?? this.idSoal,
      kodeSoal: kodeSoal ?? this.kodeSoal,
      pertanyaan: pertanyaan ?? this.pertanyaan,
      idJenisSoal: idJenisSoal ?? this.idJenisSoal,
      jenisSoal: jenisSoal ?? this.jenisSoal,
      jawabanBenar: jawabanBenar ?? this.jawabanBenar,
      poin: poin ?? this.poin,
      durasiDetik: durasiDetik ?? this.durasiDetik,
      fotoSoal: fotoSoal ?? this.fotoSoal,
      pilihan: pilihan ?? this.pilihan,
    );
  }
}

// =============================================================================
// QUIZ USER RESULT - riwayat hasil kuis siswa
// =============================================================================
class QuizUserResult {
  final int idHasil;
  final int totalPoin;
  final int poinDidapat;
  final bool isLulus;
  final String? waktuDapat;

  const QuizUserResult({
    required this.idHasil,
    required this.totalPoin,
    required this.poinDidapat,
    required this.isLulus,
    this.waktuDapat,
  });

  factory QuizUserResult.fromJson(Map<String, dynamic> json) {
    return QuizUserResult(
      idHasil: _toInt(json['id_hasil']),
      totalPoin: _toInt(json['total_poin']),
      poinDidapat: _toInt(json['poin_didapat']),
      isLulus: _toBool(json['is_lulus']),
      waktuDapat: _toStringOrNull(json['waktu_dapat']),
    );
  }
}

// =============================================================================
// QUIZ SUBMISSION RESULT - respons selesai submit kuis dari API
// =============================================================================
class QuizSubmissionResult {
  final int idHasil;
  final int idQuiz;
  final String judul;
  final int poinDidapat;
  final int totalPoin;
  final double persentase;
  final int benar;
  final int salah;
  final int totalSoal;
  final bool isLulus;
  final int poinDiberikan;
  final List<Map<String, dynamic>> evaluasi;

  const QuizSubmissionResult({
    required this.idHasil,
    required this.idQuiz,
    required this.judul,
    required this.poinDidapat,
    required this.totalPoin,
    required this.persentase,
    required this.benar,
    required this.salah,
    required this.totalSoal,
    required this.isLulus,
    required this.poinDiberikan,
    this.evaluasi = const [],
  });

  factory QuizSubmissionResult.fromJson(Map<String, dynamic> json) {
    return QuizSubmissionResult(
      idHasil: _toInt(json['id_hasil']),
      idQuiz: _toInt(json['id_quiz']),
      judul: json['judul']?.toString() ?? '',
      poinDidapat: _toInt(json['poin_didapat']),
      totalPoin: _toInt(json['total_poin']),
      persentase: (json['persentase'] is num) ? (json['persentase'] as num).toDouble() : 0.0,
      benar: _toInt(json['benar']),
      salah: _toInt(json['salah']),
      totalSoal: _toInt(json['total_soal']),
      isLulus: _toBool(json['is_lulus']),
      poinDiberikan: _toInt(json['poin_diberikan']),
      evaluasi: (json['evaluasi'] is List) ? List<Map<String, dynamic>>.from(json['evaluasi']) : const [],
    );
  }
}

// =============================================================================
// QUIZ MODEL - satu kuis utuh
// =============================================================================
class QuizModel {
  final int idQuiz;
  final String? kodeQuiz;
  final String judul;
  final String? deskripsi;

  // --- Kategori / relasi ---
  final int? idJenjang;
  final String? namaJenjang;
  final int? idTingkatQuiz;
  final String? namaTingkat;
  final int? idTipeQuiz;
  final String? namaTipe;

  // --- Pengaturan pengerjaan ---
  final String modePengerjaan;
  final int? durasiTotalMenit;
  final String? waktuKadaluarsa;
  final bool isExpired;
  final String? token;
  final bool requiresToken;

  // --- Status ---
  final String progressQuiz;
  final bool isDraft;

  // --- Tampilan ---
  final String? fotoQuiz;
  final String? coverUrl;
  final String opsiPreview;

  // --- Statistik ---
  final int questionsCount;
  final int participantsCount;
  final int totalPoints;

  /// Riwayat hasil kuis siswa yang sedang login (null jika belum dikerjakan / admin).
  final QuizUserResult? userResult;

  /// True jika kuis bertipe Wayground (timer tiap butir soal).
  bool get isWayground => modePengerjaan.toLowerCase() == 'wayground';

  /// True jika siswa sudah mengerjakan kuis ini.
  bool get hasTaken => userResult != null;

  /// True jika siswa sudah lulus pada kuis ini.
  bool get isPassed => userResult?.isLulus ?? false;

  /// Daftar butir soal di dalam kuis.
  final List<QuestionModel> soal;

  const QuizModel({
    required this.idQuiz,
    this.kodeQuiz,
    required this.judul,
    this.deskripsi,
    this.idJenjang,
    this.namaJenjang,
    this.idTingkatQuiz,
    this.namaTingkat,
    this.idTipeQuiz,
    this.namaTipe,
    this.modePengerjaan = 'wayground',
    this.durasiTotalMenit,
    this.waktuKadaluarsa,
    this.isExpired = false,
    this.token,
    this.requiresToken = false,
    this.progressQuiz = 'Draft',
    this.isDraft = true,
    this.fotoQuiz,
    this.coverUrl,
    this.opsiPreview = 'lengkap',
    this.questionsCount = 0,
    this.participantsCount = 0,
    this.totalPoints = 0,
    this.userResult,
    this.soal = const [],
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    final soalList = _parseList(json['soal'], QuestionModel.fromJson);

    return QuizModel(
      idQuiz: _toInt(json['id_quiz']),
      kodeQuiz: _toStringOrNull(json['kode_quiz']),
      judul: json['judul']?.toString() ?? '',
      deskripsi: _toStringOrNull(json['deskripsi']),
      idJenjang: _toIntOrNull(json['id_jenjang']),
      namaJenjang: _toStringOrNull(json['nama_jenjang']),
      idTingkatQuiz: _toIntOrNull(json['id_tingkatquiz']),
      namaTingkat: _toStringOrNull(json['nama_tingkat']),
      idTipeQuiz: _toIntOrNull(json['id_tipequiz']),
      namaTipe: _toStringOrNull(json['nama_tipe']),
      modePengerjaan: json['mode_pengerjaan']?.toString() ?? 'wayground',
      durasiTotalMenit: _toIntOrNull(json['durasi_total_menit']),
      waktuKadaluarsa: _toStringOrNull(json['waktu_kadaluarsa']),
      isExpired: _toBool(json['is_expired']),
      token: _toStringOrNull(json['token']),
      requiresToken: _toBool(json['requires_token']),
      progressQuiz: json['proggressQuiz']?.toString() ?? 'Draft',
      isDraft: json.containsKey('is_draft') ? _toBool(json['is_draft']) : true,
      fotoQuiz: _toStringOrNull(json['foto_quiz']),
      coverUrl: _toStringOrNull(json['cover_url']),
      opsiPreview: json['opsi_preview']?.toString() ?? 'lengkap',
      questionsCount: _toInt(
        json['questions_count'],
        fallback: soalList.length,
      ),
      participantsCount: _toInt(json['participants_count']),
      totalPoints: _toInt(
        json['total_points'],
        fallback: soalList.fold<int>(0, (sum, item) => sum + item.poin),
      ),
      userResult: json['user_result'] is Map<String, dynamic>
          ? QuizUserResult.fromJson(json['user_result'])
          : null,
      soal: soalList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idQuiz > 0) 'id_quiz': idQuiz,
      'judul': judul,
      'deskripsi': deskripsi,
      'id_jenjang': idJenjang,
      'id_tingkatquiz': idTingkatQuiz,
      'id_tipequiz': idTipeQuiz,
      'mode_pengerjaan': modePengerjaan,
      'durasi_total_menit': durasiTotalMenit,
      'waktu_kadaluarsa': waktuKadaluarsa,
      'token': token,
      'opsi_preview': opsiPreview,
      'proggressQuiz': progressQuiz,
      'action_type': isDraft ? 'draft' : 'publish',
      'soal': soal.map((e) => e.toJson()).toList(),
    };
  }

  QuizModel copyWith({
    int? idQuiz,
    String? kodeQuiz,
    String? judul,
    String? deskripsi,
    int? idJenjang,
    String? namaJenjang,
    int? idTingkatQuiz,
    String? namaTingkat,
    int? idTipeQuiz,
    String? namaTipe,
    String? modePengerjaan,
    int? durasiTotalMenit,
    String? waktuKadaluarsa,
    bool? isExpired,
    String? token,
    bool? requiresToken,
    String? progressQuiz,
    bool? isDraft,
    String? fotoQuiz,
    String? coverUrl,
    String? opsiPreview,
    int? questionsCount,
    int? participantsCount,
    int? totalPoints,
    QuizUserResult? userResult,
    List<QuestionModel>? soal,
  }) {
    return QuizModel(
      idQuiz: idQuiz ?? this.idQuiz,
      kodeQuiz: kodeQuiz ?? this.kodeQuiz,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      idJenjang: idJenjang ?? this.idJenjang,
      namaJenjang: namaJenjang ?? this.namaJenjang,
      idTingkatQuiz: idTingkatQuiz ?? this.idTingkatQuiz,
      namaTingkat: namaTingkat ?? this.namaTingkat,
      idTipeQuiz: idTipeQuiz ?? this.idTipeQuiz,
      namaTipe: namaTipe ?? this.namaTipe,
      modePengerjaan: modePengerjaan ?? this.modePengerjaan,
      durasiTotalMenit: durasiTotalMenit ?? this.durasiTotalMenit,
      waktuKadaluarsa: waktuKadaluarsa ?? this.waktuKadaluarsa,
      isExpired: isExpired ?? this.isExpired,
      token: token ?? this.token,
      requiresToken: requiresToken ?? this.requiresToken,
      progressQuiz: progressQuiz ?? this.progressQuiz,
      isDraft: isDraft ?? this.isDraft,
      fotoQuiz: fotoQuiz ?? this.fotoQuiz,
      coverUrl: coverUrl ?? this.coverUrl,
      opsiPreview: opsiPreview ?? this.opsiPreview,
      questionsCount: questionsCount ?? this.questionsCount,
      participantsCount: participantsCount ?? this.participantsCount,
      totalPoints: totalPoints ?? this.totalPoints,
      userResult: userResult ?? this.userResult,
      soal: soal ?? this.soal,
    );
  }
}
