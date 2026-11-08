import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

class NotificationSheet extends StatefulWidget {
  final VoidCallback? onOpenQrPresensi;

  const NotificationSheet({
    super.key,
    this.onOpenQrPresensi,
  });

  /// Helper statis untuk menampilkan bottom sheet notifikasi dari mana saja
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onOpenQrPresensi,
  }) {
    // Muat data notifikasi saat membuka sheet
    context.read<NotificationProvider>().fetchNotifications(silent: true);

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x9912233F),
      builder: (_) => NotificationSheet(
        onOpenQrPresensi: onOpenQrPresensi,
      ),
    );
  }

  @override
  State<NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<NotificationSheet> {
  static const _blue = Color(0xFF007FBE);
  static const _ink = Color(0xFF12233F);
  static const _muted = Color(0xFF465673);
  static const _bg = Color(0xFFF0F6FF);

  String _filter = 'Semua'; // 'Semua', 'Hari Ini', 'Terlewat'

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final allNotifs = notifProvider.notifications;
    final unreadCount = notifProvider.unreadCount;

    final filteredNotifs = allNotifs.where((n) {
      if (_filter == 'Hari Ini') return n.kategori == 'hari_ini';
      if (_filter == 'Terlewat') return n.kategori == 'terlewat';
      return true;
    }).toList();

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.nunitoSansTextTheme(Theme.of(context).textTheme),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x33007FBE),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Header Sheet: Judul, Unread Badge, & Tombol Tandai Semua Dibaca
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 16, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFDCEFFF)),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: _blue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Notifikasi Presensi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _ink,
                                ),
                              ),
                              if (unreadCount > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$unreadCount baru',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Informasi kehadiran & kelas harianmu',
                            style: TextStyle(
                              fontSize: 12,
                              color: _muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (unreadCount > 0)
                      TextButton.icon(
                        onPressed: () => notifProvider.markAllAsRead(),
                        style: TextButton.styleFrom(
                          foregroundColor: _blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.done_all_rounded, size: 16),
                        label: const Text(
                          'Baca Semua',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Filter Chips
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Row(
                  children: ['Semua', 'Hari Ini', 'Terlewat'].map((chip) {
                    final isSelected = _filter == chip;
                    int count = 0;
                    if (chip == 'Semua') count = allNotifs.length;
                    if (chip == 'Hari Ini') count = notifProvider.todayNotifications.length;
                    if (chip == 'Terlewat') count = notifProvider.missedNotifications.length;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('$chip ($count)'),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _filter = chip),
                        selectedColor: _blue,
                        backgroundColor: _bg,
                        labelStyle: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : _muted,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? _blue : const Color(0xFFDCEFFF),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Content List
              Expanded(
                child: notifProvider.isLoading && allNotifs.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: _blue),
                      )
                    : filteredNotifs.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            color: _blue,
                            onRefresh: () => notifProvider.fetchNotifications(),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                              itemCount: filteredNotifs.length,
                              itemBuilder: (ctx, idx) {
                                final notif = filteredNotifs[idx];
                                return _buildNotificationCard(
                                  notif,
                                  notifProvider,
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _bg,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDCEFFF), width: 1.5),
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 34,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak Ada Notifikasi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Semua info presensi sudah dibaca atau tidak ada jadwal presensi yang terlewat saat ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: _muted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notif,
    NotificationProvider provider,
  ) {
    final isHariIni = notif.kategori == 'hari_ini';
    final isUnread = !notif.isRead;

    final badgeBg = isHariIni ? const Color(0xFFE0F2FE) : const Color(0xFFFFE4E6);
    final badgeTextColor = isHariIni ? const Color(0xFF0284C7) : const Color(0xFFE11D48);
    final iconColor = isHariIni ? const Color(0xFF0284C7) : const Color(0xFFE11D48);
    final iconData = isHariIni ? Icons.calendar_month_rounded : Icons.warning_amber_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFF7FBFF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnread ? const Color(0xFFB2E7FC) : const Color(0xFFDCEFFF),
          width: isUnread ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB2E7FC).withValues(alpha: isUnread ? 0.6 : 0.3),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (isUnread) {
              provider.markAsRead(notif.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Atas: Badge Kategori, Waktu, & Unread Indicator
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(iconData, size: 12, color: iconColor),
                          const SizedBox(width: 4),
                          Text(
                            notif.badge,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: badgeTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notif.waktu,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: _blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Judul Notifikasi
                Text(
                  notif.judul,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                    color: _ink,
                  ),
                ),

                const SizedBox(height: 4),

                // Isi Pesan
                Text(
                  notif.pesan,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnread ? const Color(0xFF2C3E5A) : _muted,
                    height: 1.4,
                  ),
                ),

                // Tombol Aksi jika ada (Buka QR Presensi)
                if (notif.actionLabel != null && notif.actionLabel!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _blue,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF00628E),
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            provider.markAsRead(notif.id);
                            Navigator.pop(context); // Tutup sheet notifikasi
                            if (widget.onOpenQrPresensi != null) {
                              widget.onOpenQrPresensi!();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            minimumSize: const Size(0, 32),
                            shape: const StadiumBorder(),
                          ),
                          icon: const Icon(Icons.qr_code_rounded, size: 15),
                          label: Text(
                            notif.actionLabel!,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

