import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_colors.dart';
import '../../services/attendance_service.dart';

class AttendanceScannerPage extends StatefulWidget {
  final int sessionId;
  final String sessionTitle;
  final String className;

  const AttendanceScannerPage({
    super.key,
    required this.sessionId,
    required this.sessionTitle,
    required this.className,
  });

  @override
  State<AttendanceScannerPage> createState() => _AttendanceScannerPageState();
}

class _AttendanceScannerPageState extends State<AttendanceScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isSubmitting = false;
  String? _resultMessage;
  String? _resultName;
  String? _resultTime;
  bool _isResultSuccess = false;

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isSubmitting || _resultMessage != null) return;

    final values = capture.barcodes
        .map((barcode) => barcode.rawValue?.trim())
        .whereType<String>()
        .where((value) => value.isNotEmpty);
    if (values.isEmpty) return;

    unawaited(_submitScan(values.first));
  }

  Future<void> _submitScan(String token) async {
    setState(() => _isSubmitting = true);
    await _controller.stop();

    try {
      final result = await AttendanceService.scanStudent(
        sessionId: widget.sessionId,
        token: token,
      );
      if (!mounted) return;

      final student = result['siswa'] is Map
          ? Map<String, dynamic>.from(result['siswa'] as Map)
          : <String, dynamic>{};
      final status = result['status']?.toString() ?? '';

      setState(() {
        _isSubmitting = false;
        _resultMessage =
            result['pesan']?.toString() ?? 'Hasil scan diterima server.';
        _resultName = student['nama']?.toString();
        _resultTime = result['waktu']?.toString();
        _isResultSuccess =
            status == 'hadir' || status == 'terlambat' || status == 'duplikat';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _resultMessage = error.toString().replaceFirst('Exception: ', '');
        _isResultSuccess = false;
      });
    }
  }

  Future<void> _scanAgain() async {
    setState(() {
      _resultMessage = null;
      _resultName = null;
      _resultTime = null;
      _isResultSuccess = false;
      _isSubmitting = false;
    });
    await _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.className),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Text(
                  widget.sessionTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isSubmitting
                      ? 'Memeriksa QR dan mencatat presensi...'
                      : 'Arahkan kamera ke QR pada kartu presensi siswa',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                ),
              ],
            ),
          ),
          if (_resultMessage != null)
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isResultSuccess
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: _isResultSuccess
                          ? AppColors.success
                          : AppColors.error,
                      size: 30,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _resultName ?? 'Hasil scan',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_resultTime != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Waktu scan: $_resultTime',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Text(
                      _resultMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _scanAgain,
                        child: const Text('Scan QR Berikutnya'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
