import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/modules/models/module_model.dart';
import '../../admin/modules/providers/module_provider.dart';
import '../../admin/quizzes/repositories/quiz_repository.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/launcher_service.dart';
import '../../shared/widgets/native_in_app_viewer.dart';
import '../quizzes/student_quiz_player_page.dart';

class StudentModuleDetailPage extends StatefulWidget {
  final ModuleModel module;

  const StudentModuleDetailPage({super.key, required this.module});

  @override
  State<StudentModuleDetailPage> createState() =>
      _StudentModuleDetailPageState();
}

class _StudentModuleDetailPageState extends State<StudentModuleDetailPage> {
  late ModuleModel _modul;
  int _activeTabIndex = 0; // 0: Overview, 1: Catatan, 2: Kuis Modul
  bool _isLoadingFresh = false;
  bool _isMarkingDone = false;
  bool _isLoadingQuiz = false;
  bool _isSubmittingKuis = false;
  bool _showInAppPdf = false;

  // State jawaban kuis modul: { id_soal: id_pilihan }
  final Map<int, int> _selectedAnswers = {};

  static const List<Color> _kahootColors = [
    Color(0xFFE21B3C), // A - Red
    Color(0xFF1368CE), // B - Blue
    Color(0xFFD89E00), // C - Yellow
    Color(0xFF26890C), // D - Green
  ];

  static const List<String> _kahootLabels = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    _modul = widget.module;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFreshDetails();
    });
  }

  Future<void> _loadFreshDetails() async {
    setState(() => _isLoadingFresh = true);
    try {
      final prov = context.read<ModuleProvider>();
      await prov.fetchModuleById(widget.module.idModul);
      if (mounted && prov.selectedModule != null) {
        setState(() {
          _modul = prov.selectedModule!;
          _isLoadingFresh = false;
        });
      } else if (mounted) {
        setState(() => _isLoadingFresh = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingFresh = false);
    }
  }

  /// Opsi fallback untuk membuka video di YouTube eksternal jika siswa menginginkan
  Future<void> _handlePlayVideoExternal() async {
    final rawUrl = _modul.videoPlayUrl;
    if (rawUrl == null || rawUrl.trim().isEmpty) return;
    final resolvedUrl = ApiConstants.resolveMediaUrl(rawUrl) ?? rawUrl;
    await LauncherService.openUrl(resolvedUrl);
  }

  /// Membuka dokumen PDF di aplikasi eksternal (Google Drive / PDF Reader)
  Future<void> _handleOpenPdfExternal({bool useGoogleDocs = false}) async {
    final rawUrl = _modul.pdfDocumentUrl;
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
          content: Text('Berkas dokumen PDF belum diunggah atau tidak tersedia.'),
        ),
      );
      return;
    }

    final resolvedUrl = ApiConstants.resolveMediaUrl(rawUrl) ?? rawUrl;

    if (useGoogleDocs) {
      await LauncherService.openGoogleDocsPdf(resolvedUrl);
    } else {
      final success = await LauncherService.openPdf(resolvedUrl);
      if (!success && mounted) {
        await LauncherService.openGoogleDocsPdf(resolvedUrl);
      }
    }
  }

  Future<void> _handleCompleteMateri() async {
    if (_modul.isMateriSelesai) return;

    setState(() => _isMarkingDone = true);
    final provider = context.read<ModuleProvider>();
    final success = await provider.completeModule(_modul.idModul);
    setState(() => _isMarkingDone = false);

    if (!mounted) return;

    if (success) {
      if (provider.selectedModule != null) {
        setState(() => _modul = provider.selectedModule!);
      } else {
        setState(() {
          _modul = _modul.copyWith(
            isMateriSelesai: true,
            isTuntas: !_modul.hasQuizModul || _modul.isQuizLulus,
          );
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _modul.isTuntas
                      ? 'Selamat! Materi selesai dan modul tuntas (+${_modul.poinModul} EXP)'
                      : 'Materi berhasil ditandai selesai! Silakan lanjutkan ke Kuis Modul.',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
          content: Text(
            provider.error ?? 'Gagal menandai materi selesai dipelajari.',
          ),
        ),
      );
    }
  }

  Future<void> _handleSubmitKuisModul() async {
    if (_modul.soalModul.isEmpty) return;

    final int totalSoal = _modul.soalModul.length;
    final int answered = _selectedAnswers.length;

    if (answered < totalSoal) {
      final bool? proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.help_outline_rounded, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text('Belum Lengkap',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Kamu baru menjawab $answered dari $totalSoal soal kuis modul. Yakin ingin mengumpulkan sekarang?',
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Lanjutkan Mengerjakan'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              child: const Text('Kumpulkan'),
            ),
          ],
        ),
      );

      if (proceed != true) return;
    }

    setState(() => _isSubmittingKuis = true);
    final provider = context.read<ModuleProvider>();
    final result =
        await provider.submitModuleQuiz(_modul.idModul, _selectedAnswers);
    setState(() => _isSubmittingKuis = false);

    if (!mounted) return;

    if (result != null) {
      if (provider.selectedModule != null) {
        setState(() => _modul = provider.selectedModule!);
      } else {
        setState(() {
          _modul = _modul.copyWith(
            isQuizSelesai: true,
            isQuizLulus: result.isLulus,
            nilaiQuiz: result.skor,
            isTuntas: result.isTuntas,
          );
        });
      }
      _showQuizResultDialog(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
          content: Text(
            provider.error ?? 'Gagal mengumpulkan kuis modul.',
          ),
        ),
      );
    }
  }

  void _showQuizResultDialog(ModuleQuizSubmitResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final bool isLulus = result.isLulus;
        final bool isTuntas = result.isTuntas;

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isLulus
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    isLulus ? '🏆' : '⚠️',
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isLulus ? 'Lulus KKM Kuis Modul!' : 'Belum Mencapai KKM',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isLulus
                      ? const Color(0xFF065F46)
                      : const Color(0xFF991B1B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Skor Akhir: ${result.skor}% (KKM: ${result.kkm}%)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Benar',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF64748B))),
                        const SizedBox(height: 2),
                        Text(
                          '${result.benar} / ${result.totalSoal}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669)),
                        ),
                      ],
                    ),
                    Container(
                        height: 24, width: 1, color: const Color(0xFFCBD5E1)),
                    Column(
                      children: [
                        const Text('Status Modul',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF64748B))),
                        const SizedBox(height: 2),
                        Text(
                          isTuntas ? 'Tuntas ✅' : 'Belum Selesai',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isTuntas
                                ? const Color(0xFF059669)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isTuntas && result.poinDiberikan > 0
                    ? 'Selamat! Modul tuntas sempurna dan kamu mendapatkan +${result.poinDiberikan} EXP! 🎓🎉'
                    : isLulus
                        ? 'Hebat! Kamu lulus evaluasi kuis modul. Pastikan materi juga sudah ditandai selesai agar modul tuntas.'
                        : 'Nilai kamu belum mencapai KKM (${result.kkm}%). Silakan pelajari kembali materi dan coba lagi ya!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF475569),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (!isLulus)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _selectedAnswers.clear();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Coba Lagi',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (!isLulus) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Selesai',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleStartConnectedQuiz() async {
    if (_modul.idQuiz == null) return;

    setState(() => _isLoadingQuiz = true);
    try {
      final quiz = await QuizRepository().getQuizById(_modul.idQuiz!);
      if (mounted) {
        setState(() => _isLoadingQuiz = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentQuizPlayerPage(quiz: quiz),
          ),
        ).then((_) => _loadFreshDetails());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingQuiz = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFE11D48),
            behavior: SnackBarBehavior.floating,
            content: Text('Gagal memuat kuis latihan: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final modul = _modul;
    final bool isVideo = modul.isVideo;
    final String typeName =
        modul.namaTipe ?? (isVideo ? 'Video Pembelajaran' : 'Dokumen PDF');
    final Color badgeColor =
        isVideo ? const Color(0xFFDC2626) : const Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Detail Modul Belajar',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
        actions: [
          if (_isLoadingFresh)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Preview Card (In-App Player for Video or PDF Viewer)
            _buildMediaPreview(modul, isVideo),
            const SizedBox(height: 16),

            // Header Info & Metadata Card
            _buildInfoCard(modul, typeName, badgeColor),
            const SizedBox(height: 16),

            // Dual Requirement Panel (Syarat Ganda Penyelesaian)
            _buildSyaratGandaPanel(modul),
            const SizedBox(height: 16),

            // Navigation Tabs (Overview, Catatan, Kuis Modul)
            _buildTabSelector(modul),
            const SizedBox(height: 16),

            // Tab Content
            _buildTabContent(modul, isVideo),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Membangun pemutar video atau penampil dokumen PDF langsung di dalam aplikasi (In-App)
  Widget _buildMediaPreview(ModuleModel modul, bool isVideo) {
    if (isVideo) {
      final videoUrl = modul.videoPlayUrl;
      final resolvedVideoUrl = videoUrl != null
          ? ApiConstants.resolveMediaUrl(videoUrl)
          : null;

      // Pemutar video in-app (YouTube IFrame / MP4 HTML5 Video)
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NativeInAppViewer(
                youtubeId: modul.youtubeId,
                videoUrl: resolvedVideoUrl,
                height: 220,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: const Color(0xFF0F172A),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.play_circle_fill, size: 14, color: Color(0xFFEF4444)),
                        SizedBox(width: 6),
                        Text(
                          'Pemutar Video In-App',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: _handlePlayVideoExternal,
                      child: const Row(
                        children: [
                          Text(
                            'Buka di YouTube ↗',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Tampilan PDF
    final pdfUrl = modul.pdfDocumentUrl;
    final resolvedPdfUrl =
        pdfUrl != null ? ApiConstants.resolveMediaUrl(pdfUrl) : null;

    if (_showInAppPdf && resolvedPdfUrl != null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: const Color(0xFF1E293B),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.picture_as_pdf, size: 16, color: Color(0xFF60A5FA)),
                        SizedBox(width: 6),
                        Text(
                          'Pembaca PDF In-App',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => setState(() => _showInAppPdf = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Tutup Pratinjau ✕',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              NativeInAppViewer(
                isPdf: true,
                videoUrl: resolvedPdfUrl,
                height: 420,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 44,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Dokumen Pembelajaran PDF',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                modul.fileMateri ?? 'Materi siap dibaca langsung di HP',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _showInAppPdf = true),
                    icon: const Icon(Icons.chrome_reader_mode_rounded, size: 16),
                    label: const Text('Baca di Aplikasi 📖', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1D4ED8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _handleOpenPdfExternal(),
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const Text('Aplikasi Luar ↗', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      ModuleModel modul, String typeName, Color badgeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  typeName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
              if (modul.namaJenjang != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    modul.namaJenjang!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${modul.poinModul} EXP',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: modul.isTuntas
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  modul.isTuntas ? 'Tuntas Sempurna ✅' : 'Belum Tuntas ⏳',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: modul.isTuntas
                        ? const Color(0xFF059669)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            modul.judulModul,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // Panel Syarat Penyelesaian Modul (Syarat Ganda: 1. Materi + 2. Kuis Modul)
  Widget _buildSyaratGandaPanel(ModuleModel modul) {
    final bool isTuntas = modul.isTuntas;
    final bool isMateriSelesai = modul.isMateriSelesai;
    final bool isQuizLulus = modul.isQuizLulus;
    final bool hasQuiz = modul.hasQuizModul;
    final int kkm = modul.kkmQuiz > 0 ? modul.kkmQuiz : 70;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTuntas ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTuntas
              ? const Color(0xFFA7F3D0)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar Syarat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isTuntas
                          ? const Color(0xFF059669)
                          : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        isTuntas ? Icons.check : Icons.track_changes_rounded,
                        color:
                            isTuntas ? Colors.white : const Color(0xFF4F46E5),
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTuntas
                            ? 'Modul Tuntas Sempurna!'
                            : 'Syarat Penyelesaian Modul',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isTuntas
                              ? const Color(0xFF065F46)
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        isTuntas
                            ? 'Materi & evaluasi kuis modul tuntas.'
                            : 'Selesaikan 2 langkah untuk klaim EXP.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isTuntas
                              ? const Color(0xFF047857)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isTuntas
                      ? const Color(0xFF059669)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🏆 +${modul.poinModul} EXP',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isTuntas ? Colors.white : const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Langkah 1: Pelajari Materi
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMateriSelesai
                  ? Colors.white
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isMateriSelesai
                    ? const Color(0xFFA7F3D0)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isMateriSelesai
                        ? const Color(0xFF059669)
                        : const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isMateriSelesai
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : const Text('1',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1. Pelajari Materi',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        isMateriSelesai
                            ? 'Selesai dipelajari ✓'
                            : 'Tonton video di atas atau baca materi',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isMateriSelesai
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isMateriSelesai
                              ? const Color(0xFF059669)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isMateriSelesai)
                  ElevatedButton(
                    onPressed:
                        _isMarkingDone ? null : _handleCompleteMateri,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isMarkingDone
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Tandai Selesai',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700)),
                  )
                else
                  const Text('Tuntas ✓',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF059669))),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Langkah 2: Kuis Evaluasi Modul
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isQuizLulus
                  ? Colors.white
                  : (modul.isQuizSelesai
                      ? const Color(0xFFFFFBEB)
                      : const Color(0xFFF8FAFC)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isQuizLulus
                    ? const Color(0xFFA7F3D0)
                    : (modul.isQuizSelesai
                        ? const Color(0xFFFDE68A)
                        : const Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isQuizLulus
                        ? const Color(0xFF059669)
                        : (modul.isQuizSelesai
                            ? const Color(0xFFD97706)
                            : const Color(0xFFE2E8F0)),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isQuizLulus
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : const Text('2',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2. Kuis Modul (KKM: $kkm%)',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        !hasQuiz
                            ? 'Tanpa Kuis Evaluasi (Bebas Kuis)'
                            : isQuizLulus
                                ? 'Lulus KKM (Nilai: ${modul.nilaiQuiz}%)'
                                : modul.isQuizSelesai
                                    ? 'Remedial (Nilai: ${modul.nilaiQuiz}%)'
                                    : 'Belum Dikerjakan (${modul.soalModul.length} Soal)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: (isQuizLulus || modul.isQuizSelesai)
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isQuizLulus
                              ? const Color(0xFF059669)
                              : (modul.isQuizSelesai
                                  ? const Color(0xFFB45309)
                                  : const Color(0xFF94A3B8)),
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasQuiz)
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _activeTabIndex = 2);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isQuizLulus
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFF4F46E5),
                      foregroundColor: isQuizLulus
                          ? const Color(0xFF334155)
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 32),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(isQuizLulus ? 'Lihat Kuis' : 'Kerjakan',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700)),
                  )
                else
                  const Text('Bebas Kuis',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3 Tabs: Overview, Catatan, Kuis Modul
  Widget _buildTabSelector(ModuleModel modul) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          _buildSingleTab(0, 'Overview', null),
          _buildSingleTab(
            1,
            'Catatan',
            modul.catatan.isNotEmpty
                ? '${modul.catatan.length}'
                : null,
          ),
          _buildSingleTab(
            2,
            'Kuis Modul',
            modul.isQuizLulus
                ? '✓ Lulus'
                : (modul.hasQuizModul
                    ? '${modul.soalModul.length} Soal'
                    : null),
            isBadgeSuccess: modul.isQuizLulus,
          ),
        ],
      ),
    );
  }

  Widget _buildSingleTab(int index, String title, String? badgeText,
      {bool isBadgeSuccess = false}) {
    final bool isActive = _activeTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    isActive ? const Color(0xFF4F46E5) : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive
                      ? const Color(0xFF4F46E5)
                      : const Color(0xFF64748B),
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isBadgeSuccess
                        ? const Color(0xFFD1FAE5)
                        : (isActive
                            ? const Color(0xFFEEF2FF)
                            : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isBadgeSuccess
                          ? const Color(0xFF065F46)
                          : (isActive
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFF64748B)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(ModuleModel modul, bool isVideo) {
    switch (_activeTabIndex) {
      case 1:
        return _buildTabCatatan(modul);
      case 2:
        return _buildTabKuisModul(modul);
      case 0:
      default:
        return _buildTabOverview(modul, isVideo);
    }
  }

  // TAB 1: OVERVIEW
  Widget _buildTabOverview(ModuleModel modul, bool isVideo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description text matching web
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tentang Modul Ini',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pelajari materi "${modul.judulModul}" ini dengan seksama. Putar video langsung pada pemutar di atas, baca ringkasan catatan dari guru, dan selesaikan kuis evaluasi modul untuk mengklaim EXP!',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF475569),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Action card if materi belum selesai
        if (!modul.isMateriSelesai) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sudah Selesai Menyimak Materi?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF312E81),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tandai materi selesai untuk melengkapi langkah pertama penyelesaian modul.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4338CA),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: _isMarkingDone ? null : _handleCompleteMateri,
                    icon: _isMarkingDone
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check, size: 18),
                    label: Text(
                      _isMarkingDone
                          ? 'Menyimpan Progres...'
                          : 'Tandai Selesai Menonton/Membaca',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Resource info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isVideo ? Icons.ondemand_video_rounded : Icons.description_outlined,
                  size: 22,
                  color: const Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isVideo ? 'Media Video Pembelajaran' : 'Bahan Dokumen PDF',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      modul.fileMateri ?? 'Tersedia di web e-learning',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Connected Quiz (Latihan Soal Terkait) if exists
        if (modul.idQuiz != null) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E1065), Color(0xFF581C87)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.videogame_asset_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Latihan Soal Terkait (Kuis)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  modul.quizJudul != null
                      ? 'Latih kemampuanmu melalui kuis gamifikasi: "${modul.quizJudul}"'
                      : 'Kerjakan latihan soal gamifikasi terkait materi ini!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isLoadingQuiz ? null : _handleStartConnectedQuiz,
                    icon: _isLoadingQuiz
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Color(0xFF581C87)),
                          )
                        : const Icon(Icons.play_arrow_rounded, size: 18),
                    label: Text(
                      _isLoadingQuiz
                          ? 'Memuat Kuis...'
                          : 'Buka Latihan Soal Terkait ⚡',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF581C87),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // TAB 2: CATATAN
  Widget _buildTabCatatan(ModuleModel modul) {
    if (modul.catatan.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Column(
          children: [
            Icon(Icons.notes_rounded, size: 48, color: Color(0xFFCBD5E1)),
            SizedBox(height: 12),
            Text(
              'Belum Ada Catatan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF475569),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Guru belum menambahkan catatan ringkasan untuk modul ini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: modul.catatan.map((catatan) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bookmark_border_rounded,
                        size: 18, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      catatan.judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                catatan.isi,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF475569),
                  height: 1.6,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // TAB 3: KUIS MODUL (EVALUASI MANDIRI DENGAN KAHOOT CHOICES)
  Widget _buildTabKuisModul(ModuleModel modul) {
    if (!modul.hasQuizModul) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Column(
          children: [
            Text('📖', style: TextStyle(fontSize: 40)),
            SizedBox(height: 12),
            Text(
              'Modul Ini Bebas Kuis Evaluasi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Anda hanya perlu menyelesaikan materi untuk menandai modul ini tuntas dan mengklaim poin EXP.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    final int kkm = modul.kkmQuiz > 0 ? modul.kkmQuiz : 70;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status & KKM Info Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: modul.isQuizLulus
                ? const Color(0xFFF0FDF4)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: modul.isQuizLulus
                  ? const Color(0xFFA7F3D0)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Evaluasi Pemahaman Modul',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Batas Kelulusan KKM: $kkm% (${modul.soalModul.length} Soal)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (modul.isQuizLulus)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '✓ Lulus (${modul.nilaiQuiz}%)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              else if (modul.isQuizSelesai)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    border: Border.all(color: const Color(0xFFFCD34D)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Remedial (${modul.nilaiQuiz}%)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // List Soal Modul
        ...modul.soalModul.asMap().entries.map((entry) {
          final int sIdx = entry.key;
          final question = entry.value;

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Soal #${sIdx + 1} dari ${modul.soalModul.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                    Text(
                      'Bobot: +${question.poin} Poin',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Question Text
                Text(
                  question.pertanyaan,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Choices
                Column(
                  children: question.pilihan.asMap().entries.map((pEntry) {
                    final int pIdx = pEntry.key;
                    final option = pEntry.value;
                    final Color color =
                        _kahootColors[pIdx % _kahootColors.length];
                    final String label = option.label.isNotEmpty
                        ? option.label
                        : _kahootLabels[pIdx % _kahootLabels.length];
                    final bool isSelected =
                        _selectedAnswers[question.idSoal] == option.idPilihan;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAnswers[question.idSoal] = option.idPilihan;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFEEF2FF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4F46E5)
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                option.teksPilihan,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: Color(0xFF4F46E5), size: 18),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isSubmittingKuis ? null : _handleSubmitKuisModul,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSubmittingKuis
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    '🚀 Kumpulkan Jawaban Kuis Modul',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      ],
    );
  }
}
