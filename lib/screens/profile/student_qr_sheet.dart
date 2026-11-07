import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/api_constants.dart';

/// Uses the server-issued attendance payload; never fabricates an identity.
class StudentQrSheet extends StatefulWidget {
  const StudentQrSheet({super.key, required this.user});
  final Map<String, dynamic> user;
  @override
  State<StudentQrSheet> createState() => _StudentQrSheetState();
}

class _StudentQrSheetState extends State<StudentQrSheet> {
  static const _blue = Color(0xFF007FBE);
  static const _ink = Color(0xFF12233F);
  bool _saving = false;
  String get _payload => widget.user['qr_payload']?.toString().trim() ?? '';

  String _value(String key, [String fallback = '-']) =>
      widget.user[key]?.toString() ?? fallback;

  Widget _qr(double size) => QrImageView(
    data: _payload,
    version: QrVersions.auto,
    size: size,
    padding: const EdgeInsets.all(14),
    backgroundColor: Colors.white,
    eyeStyle: const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: Color(0xFF006B99),
    ),
    dataModuleStyle: const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: Color(0xFF006B99),
    ),
  );

  Future<void> _download() async {
    setState(() => _saving = true);
    try {
      final bytes = await QrPainter(
        data: _payload,
        version: QrVersions.auto,
        gapless: true,
        color: const Color(0xFF006B99),
        emptyColor: Colors.white,
      ).toImageData(1024, format: ui.ImageByteFormat.png);
      if (bytes == null) throw StateError('QR tidak dapat dibuat');
      await const MethodChannel('com.arrava.app/launcher')
          .invokeMethod<void>('saveQr', {
            'bytes': bytes.buffer.asUint8List(
              bytes.offsetInBytes,
              bytes.lengthInBytes,
            ),
            'filename': 'ARRAVA-QR-Siswa.png',
          });
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('QR berhasil disimpan.')));
    } on PlatformException catch (e) {
      if (mounted && e.code != 'CANCELLED') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Gagal menyimpan QR.')),
        );
      }
    } on MissingPluginException {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unduh QR tersedia di aplikasi Android.'),
          ),
        );
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan QR. Silakan coba lagi.'),
          ),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _fullscreen() => Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('QR Presensi Siswa')),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _value('nama', 'Siswa'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (_, c) => _qr(c.maxWidth.clamp(0, 440).toDouble()),
                  ),
                  const SizedBox(height: 20),
                  Text('NISN: ${_value('nisn')}'),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final avatar = ApiConstants.resolveMediaUrl(
      widget.user['foto_profil']?.toString(),
    );
    final available = _payload.isNotEmpty;
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.nunitoSansTextTheme(Theme.of(context).textTheme),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .88,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD5E1EF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const Spacer(),
                        IconButton.filledTonal(
                          onPressed: () => Navigator.pop(context),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFEBEDFF),
                          ),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF465673),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_rounded, color: _blue, size: 26),
                        SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Kartu QR Siswa',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              color: _ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECEDFF),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        available
                            ? '● QR Presensi Siswa'
                            : '● QR Belum Tersedia',
                        style: const TextStyle(
                          color: _blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: const Color(0xFFF0F6FF),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: const Color(0xFFD2F1FC),
                            foregroundImage: avatar == null
                                ? null
                                : NetworkImage(avatar),
                            child: const Icon(
                              Icons.person_rounded,
                              color: _blue,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_value('nama', 'Siswa')} ⭐',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: _ink,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'NISN: ${_value('nisn')} • ${_value('nama_jenjang')}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF465673),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFF3FAFF), Color(0xFFECF5FF)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x16000000),
                            blurRadius: 4,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (available)
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.white,
                              child: LayoutBuilder(
                                builder: (_, c) => CustomPaint(
                                  foregroundPainter: _QrCorners(),
                                  child: _qr(
                                    c.maxWidth.clamp(0, 230).toDouble(),
                                  ),
                                ),
                              ),
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 55),
                              child: Text(
                                'Data QR presensi belum tersedia.\nHubungi guru atau admin sekolah.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: _ink, height: 1.5),
                              ),
                            ),
                          const SizedBox(height: 18),
                          const Text(
                            'Gunakan QR ini saat melakukan presensi',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6C91AF),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: const Color(0xFFF0F6FF),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFF3DC3F0),
                            child: Icon(
                              Icons.photo_camera,
                              size: 18,
                              color: _blue,
                            ),
                          ),
                          SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              'Arahkan layar ini ke kamera scanner milik Bapak/Ibu Guru.',
                              style: TextStyle(
                                color: Color(0xFF465673),
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: available && !_saving ? _download : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFEBEDFF),
                              foregroundColor: _blue,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            icon: const Icon(Icons.save_alt_rounded, size: 18),
                            label: Text(
                              _saving ? 'Menyimpan...' : 'Unduh QR',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: available ? _fullscreen : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: _blue,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            icon: const Icon(Icons.fullscreen, size: 19),
                            label: const Text(
                              'Layar Penuh',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Kembali ke Profil Siswa',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF465673),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QrCorners extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF007FBE)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    const length = 19.0;
    for (final corner in [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ]) {
      final dx = corner.dx == 0 ? length : -length;
      final dy = corner.dy == 0 ? length : -length;
      canvas.drawPath(
        Path()
          ..moveTo(corner.dx + dx, corner.dy)
          ..lineTo(corner.dx, corner.dy)
          ..lineTo(corner.dx, corner.dy + dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
