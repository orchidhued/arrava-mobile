class NotificationModel {
  final String id;
  final String kategori; // 'hari_ini', 'terlewat'
  final String tipe; // 'info', 'danger'
  final String badge;
  final String? badgeColor;
  final String icon; // 'calendar', 'alert'
  final String judul;
  final String pesan;
  final String waktu;
  final String? actionUrl;
  final String? actionLabel;
  final int? anakId;
  final String? namaAnak;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.kategori,
    required this.tipe,
    required this.badge,
    this.badgeColor,
    required this.icon,
    required this.judul,
    required this.pesan,
    required this.waktu,
    this.actionUrl,
    this.actionLabel,
    this.anakId,
    this.namaAnak,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? 'umum',
      tipe: json['tipe']?.toString() ?? 'info',
      badge: json['badge']?.toString() ?? 'Notifikasi',
      badgeColor: json['badge_color']?.toString(),
      icon: json['icon']?.toString() ?? 'calendar',
      judul: json['judul']?.toString() ?? 'Pemberitahuan',
      pesan: json['pesan']?.toString() ?? '',
      waktu: json['waktu']?.toString() ?? '',
      actionUrl: json['action_url']?.toString(),
      actionLabel: json['action_label']?.toString(),
      anakId: json['anak_id'] != null ? int.tryParse(json['anak_id'].toString()) : null,
      namaAnak: json['nama_anak']?.toString(),
      isRead: json['is_read'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kategori': kategori,
      'tipe': tipe,
      'badge': badge,
      'badge_color': badgeColor,
      'icon': icon,
      'judul': judul,
      'pesan': pesan,
      'waktu': waktu,
      'action_url': actionUrl,
      'action_label': actionLabel,
      'anak_id': anakId,
      'nama_anak': namaAnak,
      'is_read': isRead,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? kategori,
    String? tipe,
    String? badge,
    String? badgeColor,
    String? icon,
    String? judul,
    String? pesan,
    String? waktu,
    String? actionUrl,
    String? actionLabel,
    int? anakId,
    String? namaAnak,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      kategori: kategori ?? this.kategori,
      tipe: tipe ?? this.tipe,
      badge: badge ?? this.badge,
      badgeColor: badgeColor ?? this.badgeColor,
      icon: icon ?? this.icon,
      judul: judul ?? this.judul,
      pesan: pesan ?? this.pesan,
      waktu: waktu ?? this.waktu,
      actionUrl: actionUrl ?? this.actionUrl,
      actionLabel: actionLabel ?? this.actionLabel,
      anakId: anakId ?? this.anakId,
      namaAnak: namaAnak ?? this.namaAnak,
      isRead: isRead ?? this.isRead,
    );
  }
}

