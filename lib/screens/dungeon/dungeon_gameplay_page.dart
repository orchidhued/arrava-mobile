import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../admin/dungeon/providers/dungeon_provider.dart';
import '../../core/constants/api_constants.dart';
import 'widgets/dungeon_animation_overlay.dart';
import 'widgets/dungeon_floor_loader.dart';
import 'widgets/dungeon_pixel_heart.dart';

class DungeonGameplayPage extends StatefulWidget {
  final int idMapel;
  final String namaMapel;

  const DungeonGameplayPage({
    super.key,
    required this.idMapel,
    required this.namaMapel,
  });

  @override
  State<DungeonGameplayPage> createState() => _DungeonGameplayPageState();
}

class _DungeonGameplayPageState extends State<DungeonGameplayPage>
    with SingleTickerProviderStateMixin {
  bool _isSubmitting = false;

  // Timer Soal (State Lokal Widget)
  Timer? _timer;
  int _durasiTotal = 25;
  int _sisaDetik = 25;

  // State Jawaban Terpilih (Visual Lokal)
  dynamic _selectedJawaban;
  final TextEditingController _isianController = TextEditingController();
  bool? _answerFeedback; // true jika benar, false jika salah, null jika normal

  // State Animasi Overlay Khas Web Elearningarrava
  bool _showStartOverlay = false;
  bool _showLoseHeartOverlay = false;
  int _prevLivesForAnim = 3;
  int _newLivesForAnim = 3;
  bool _isTimeoutForAnim = false;
  bool _isGameOverPending = false;

  // State Animasi Naik Lantai (FloorLoader) Khas Web Elearningarrava
  bool _showFloorLoader = false;
  int _floorFrom = 1;
  int _floorTo = 2;
  Map<String, dynamic>? _pendingNextSoal;
  int _pendingSkor = 0;
  int _pendingLantai = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mulaiPetualangan();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _isianController.dispose();
    super.dispose();
  }

  Future<void> _mulaiPetualangan() async {
    final prov = context.read<DungeonProvider>();
    final success = await prov.mulaiPetualangan(widget.idMapel);
    if (!mounted) return;

    if (success) {
      // Munculkan animasi pembuka (3 Hati Jatuh + Countdown 3, 2, 1, MULAI!)
      setState(() => _showStartOverlay = true);
    }
  }

  void _siapkanSoalBaru(Map<String, dynamic>? soal) {
    _timer?.cancel();
    _selectedJawaban = null;
    _answerFeedback = null;
    _isianController.clear();

    if (soal == null) return;

    final durasi = (soal['durasi_detik'] as num?)?.toInt() ?? 25;
    setState(() {
      _durasiTotal = durasi > 0 ? durasi : 25;
      _sisaDetik = _durasiTotal;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_sisaDetik > 1) {
        setState(() => _sisaDetik--);
      } else {
        timer.cancel();
        setState(() => _sisaDetik = 0);
        _handleWaktuHabis();
      }
    });
  }

  void _handleWaktuHabis() {
    final prov = context.read<DungeonProvider>();
    if (_isSubmitting || prov.soalAktif == null) return;
    _kirimJawaban(jawaban: '__TIMEOUT__');
  }

  Future<void> _kirimJawaban({required dynamic jawaban}) async {
    final prov = context.read<DungeonProvider>();
    if (_isSubmitting || prov.soalAktif == null) return;

    final int prevNyawa = prov.nyawa;
    final int prevLantai = prov.lantai;
    _timer?.cancel();
    setState(() {
      _isSubmitting = true;
      _selectedJawaban = jawaban;
    });

    try {
      final hasil = await prov.jawabSoal(
        idMapel: widget.idMapel,
        jawaban: jawaban,
      );

      if (!mounted) return;

      final Map<String, dynamic>? statusSesi = hasil['status_sesi'] is Map
          ? Map<String, dynamic>.from(hasil['status_sesi'] as Map)
          : null;

      final bool isBenar = hasil['is_benar'] == true || hasil['benar'] == true;
      final bool isGameOver =
          (statusSesi?['nyawa'] != null &&
              (statusSesi!['nyawa'] as num).toInt() <= 0) ||
          (statusSesi?['selesai'] == true &&
              statusSesi?['alasan_selesai'] == 'game_over') ||
          hasil['is_game_over'] == true;
      final int skorTotal = prov.skor;
      final int lantai = prov.lantai;
      final soalBerikutnya = prov.soalAktif;

      if (isBenar) {
        // Efek visual benar: highlight tombol hijau
        setState(() => _answerFeedback = true);

        if (lantai > prevLantai) {
          // Naik Lantai! Tampilkan animasi FloorLoader khas web
          await Future.delayed(const Duration(milliseconds: 350));
          if (!mounted) return;

          setState(() {
            _showFloorLoader = true;
            _floorFrom = prevLantai;
            _floorTo = lantai;
            _pendingNextSoal = soalBerikutnya;
            _pendingSkor = skorTotal;
            _pendingLantai = lantai;
          });
        } else {
          // Masih di lantai yang sama: tunggu 750ms lalu lanjut
          await Future.delayed(const Duration(milliseconds: 750));
          if (!mounted) return;

          setState(() {
            _isSubmitting = false;
            _answerFeedback = null;
          });

          if (soalBerikutnya != null) {
            _siapkanSoalBaru(soalBerikutnya);
          } else {
            _showVictoryDialog(skor: skorTotal, lantai: lantai);
          }
        }
      } else {
        // Efek visual salah / timeout: jalankan animasi pecah hati + suara kalah khas web
        setState(() {
          _answerFeedback = false;
          _isGameOverPending = isGameOver;
          _prevLivesForAnim = prevNyawa;
          _newLivesForAnim = prov.nyawa;
          _isTimeoutForAnim = (jawaban == '__TIMEOUT__');
          _showLoseHeartOverlay = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _answerFeedback = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFF43F5E),
          ),
        );
      }
    }
  }

  void _showGameOverDialog({required int skor, required int lantai}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF43F5E), width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66F43F5E),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                // <-- DIBUNGKUS INI AGAR TIDAK PERNAH OVERFLOW
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PixelHeartSprite(size: 64, state: 'dead'),
                    const SizedBox(height: 14),
                    Text(
                      'GAME OVER',
                      style: GoogleFonts.fredoka(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF43F5E),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Seluruh nyawamu telah habis di kedalaman dungeon.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Skor Akhir',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$skor',
                                style: GoogleFonts.fredoka(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFBBF24),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 34,
                            color: Colors.white24,
                          ),
                          Column(
                            children: [
                              const Text(
                                'Lantai Tertinggi',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lt. $lantai',
                                style: GoogleFonts.fredoka(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF38BDF8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.white30,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: const Text(
                              'Ke Lobby',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _mulaiPetualangan();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0284C7),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: const Text(
                              'Coba Lagi',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showVictoryDialog({required int skor, required int lantai}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF10B981), width: 3),
              ),
              child: SingleChildScrollView(
                // <-- DIBUNGKUS INI
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('👑', style: TextStyle(fontSize: 54)),
                    const SizedBox(height: 8),
                    Text(
                      'DUNGEON TUNTAS!',
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Luar biasa! Kamu menaklukkan seluruh soal di dungeon ini!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Total Skor: $skor Poin',
                      style: GoogleFonts.fredoka(
                        fontSize: 20,
                        color: const Color(0xFFFBBF24),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Klaim Kemenangan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _konfirmasiKeluar() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Tinggalkan Petualangan?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Apakah kamu yakin ingin menyerah dan keluar? Skor yang diperoleh sampai saat ini akan disimpan.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Lanjut Main',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF43F5E),
              ),
              child: const Text(
                'Ya, Menyerah',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      if (!mounted) return true;
      await context.read<DungeonProvider>().selesaiPetualangan(widget.idMapel);
      return true;
    }
    return false;
  }

  Future<void> _handleTombolKeluar() async {
    final shouldLeave = await _konfirmasiKeluar();
    if (shouldLeave && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DungeonProvider>();
    final bool isLoading = prov.isLoading;
    final String? errorMessage = prov.error;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleTombolKeluar();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF071224),
        body: Stack(
          children: [
            // 1. Tampilan Utama Arena Game
            if (isLoading && prov.soalAktif == null)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF38BDF8)),
                    SizedBox(height: 16),
                    Text(
                      'Mempersiapkan Arena...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              )
            else if (errorMessage != null && prov.soalAktif == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFF43F5E),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _mulaiPetualangan,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildArenaContent(prov),

            // 2. Overlay Animasi Mulai (3 Hati Drop + Countdown 3, 2, 1, MULAI!)
            if (_showStartOverlay)
              DungeonAnimationOverlay(
                type: DungeonAnimType.start,
                onComplete: () {
                  if (!mounted) return;
                  setState(() => _showStartOverlay = false);
                  _siapkanSoalBaru(prov.soalAktif);
                },
              ),

            // 3. Overlay Animasi Kehilangan Hati (Screen Shake + Heart Break + YOU LOSE / -1 HATI)
            if (_showLoseHeartOverlay)
              DungeonAnimationOverlay(
                type: DungeonAnimType.loseLife,
                prevLives: _prevLivesForAnim,
                newLives: _newLivesForAnim,
                isTimeout: _isTimeoutForAnim,
                onComplete: () {
                  if (!mounted) return;
                  setState(() {
                    _showLoseHeartOverlay = false;
                    _isSubmitting = false;
                    _answerFeedback = null;
                  });

                  if (_isGameOverPending) {
                    _showGameOverDialog(skor: prov.skor, lantai: prov.lantai);
                  } else if (prov.soalAktif != null) {
                    _siapkanSoalBaru(prov.soalAktif);
                  } else {
                    _showVictoryDialog(skor: prov.skor, lantai: prov.lantai);
                  }
                },
              ),

            // 4. Overlay Animasi Naik Lantai (FloorLoader runner pixel + 20 balok progress)
            if (_showFloorLoader)
              DungeonFloorLoader(
                from: _floorFrom,
                to: _floorTo,
                onDone: () {
                  if (!mounted) return;
                  setState(() {
                    _showFloorLoader = false;
                    _isSubmitting = false;
                    _answerFeedback = null;
                  });

                  if (_pendingNextSoal != null) {
                    _siapkanSoalBaru(_pendingNextSoal);
                  } else {
                    _showVictoryDialog(
                      skor: _pendingSkor,
                      lantai: _pendingLantai,
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildArenaContent(DungeonProvider prov) {
    final soal = prov.soalAktif;
    final pilihanList =
        (soal?['pilihan'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final String tingkat =
        soal?['tingkat_soal']?.toString().toUpperCase() ?? 'SEDANG';
    final Color tingkatColor = tingkat == 'MUDAH'
        ? const Color(0xFF10B981)
        : (tingkat == 'SULIT'
              ? const Color(0xFFA855F7)
              : const Color(0xFFF59E0B));

    final double progressTimer = (_sisaDetik / _durasiTotal).clamp(0.0, 1.0);
    final Color timerColor = progressTimer > 0.4
        ? const Color(0xFF10B981)
        : (progressTimer > 0.2
              ? const Color(0xFFFBBF24)
              : const Color(0xFFF43F5E));

    return SafeArea(
      child: Column(
        children: [
          // ===================================================================
          // 1. TOP HUD (Nyawa ❤️, Lantai 🏰, Combo 🔥, Skor 🏆, Tombol Keluar ✕)
          // ===================================================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF0A182E),
              border: Border(
                bottom: BorderSide(color: Color(0xFF1E293B), width: 1.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol Keluar / Menyerah
                InkWell(
                  onTap: _handleTombolKeluar,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Menyerah',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Lantai & Combo
                Column(
                  children: [
                    Text(
                      'LANTAI ${prov.lantai}',
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                    if (prov.combo > 1)
                      Text(
                        '🔥 x${prov.multiplier.toStringAsFixed(1)} (Combo ${prov.combo})',
                        style: const TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                  ],
                ),

                // 3 Hati (Nyawa) di HUD dengan Animasi Transisi Halus
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (idx) {
                    final bool isAlive = idx < prov.nyawa;
                    return Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: isAlive ? 1.0 : 0.35,
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 250),
                          scale: isAlive ? 1.0 : 0.88,
                          child: PixelHeartSprite(
                            size: 24,
                            state: isAlive ? 'full' : 'dead',
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // ===================================================================
          // 2. COUNTDOWN TIMER LINEAR PROGRESS BAR
          // ===================================================================
          LinearProgressIndicator(
            value: progressTimer,
            minHeight: 5,
            backgroundColor: const Color(0xFF1E293B),
            valueColor: AlwaysStoppedAnimation<Color>(timerColor),
          ),

          // ===================================================================
          // 3. SOAL CARD & PILIHAN JAWABAN (Scrollable)
          // ===================================================================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skor Saat Ini & Badge Tingkat Kesulitan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: tingkatColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: tingkatColor, width: 1.2),
                        ),
                        child: Text(
                          tingkat,
                          style: TextStyle(
                            color: tingkatColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: timerColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_sisaDetik dtk',
                            style: TextStyle(
                              color: timerColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text('🏆 ', style: TextStyle(fontSize: 14)),
                          Text(
                            '${prov.skor} Poin',
                            style: GoogleFonts.fredoka(
                              color: const Color(0xFFFBBF24),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Teks Pertanyaan Soal
                  Text(
                    soal?['pertanyaan']?.toString() ?? 'Memuat soal...',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),

                  // Gambar Soal jika ada
                  if (soal?['gambar'] != null &&
                      soal!['gambar'].toString().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        ApiConstants.resolveMediaUrl(
                              soal['gambar'].toString(),
                            ) ??
                            '',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ===========================================================
                  // 4. DAFTAR PILIHAN JAWABAN (Pilihan Ganda / Isian)
                  // ===========================================================
                  if (pilihanList.isNotEmpty) ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pilihanList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final pil = pilihanList[index];
                        final idPilihan = pil['id_pilihan'];
                        final teksPilihan =
                            pil['teks_pilihan']?.toString() ?? '';
                        final bool isSelected = _selectedJawaban == idPilihan;

                        Color btnColor = const Color(0xFF0F1E36);
                        Color borderColor = const Color(0xFF1E3A5F);
                        Color shadowColor = const Color(0xFF081426);

                        if (isSelected) {
                          if (_answerFeedback == true) {
                            btnColor = const Color(0xFF059669);
                            borderColor = const Color(0xFF34D399);
                            shadowColor = const Color(0xFF064E3B);
                          } else if (_answerFeedback == false) {
                            btnColor = const Color(0xFFE11D48);
                            borderColor = const Color(0xFFFB7185);
                            shadowColor = const Color(0xFF881337);
                          } else {
                            btnColor = const Color(0xFF0284C7);
                            borderColor = const Color(0xFF38BDF8);
                            shadowColor = const Color(0xFF0369A1);
                          }
                        }

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isSubmitting
                                ? null
                                : () => _kirimJawaban(jawaban: idPilihan),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: btnColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: borderColor,
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: shadowColor,
                                    offset: Offset(0, isSelected ? 2 : 4),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              transform: Matrix4.translationValues(
                                0,
                                isSelected ? 2 : 0,
                                0,
                              ),
                              child: Row(
                                children: [
                                  // Label A, B, C, D
                                  Container(
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF1E3A5F),
                                    ),
                                    child: Text(
                                      String.fromCharCode(65 + index),
                                      style: TextStyle(
                                        color: isSelected
                                            ? (_answerFeedback == true
                                                  ? const Color(0xFF059669)
                                                  : (_answerFeedback == false
                                                        ? const Color(
                                                            0xFFE11D48,
                                                          )
                                                        : const Color(
                                                            0xFF0284C7,
                                                          )))
                                            : Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Teks Pilihan
                                  Expanded(
                                    child: Text(
                                      teksPilihan,
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    // Input Isian Singkat
                    TextField(
                      controller: _isianController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ketik jawaban singkat...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF0F1E36),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF1E3A5F),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _kirimJawaban(
                                jawaban: _isianController.text.trim(),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Kirim Jawaban',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
