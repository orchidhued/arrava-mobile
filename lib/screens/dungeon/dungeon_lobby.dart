import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../admin/dungeon/providers/dungeon_provider.dart';
import 'dungeon_gameplay_page.dart';

class DungeonLobbyPage extends StatefulWidget {
  const DungeonLobbyPage({super.key});

  @override
  State<DungeonLobbyPage> createState() => _DungeonLobbyPageState();
}

class _DungeonLobbyPageState extends State<DungeonLobbyPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DungeonProvider>().fetchDungeons();
    });
  }

  static Map<String, dynamic> getDungeonMeta(String namaMapel, int index) {
    final nama = namaMapel.toLowerCase();
    if (nama.contains('matematika')) {
      return {
        'img': 'assets/dungeon/dungeon-sunset-crags.webp',
        'desc': 'Hitung cepat, tebak pola, dan jaga hati terakhirmu. Makin dalam kamu turun, makin sulit angkanya.',
      };
    } else if (nama.contains('ipa') || nama.contains('alam')) {
      return {
        'img': 'assets/dungeon/dungeon-sunset-cave.webp',
        'desc': 'Dari sel sampai galaksi. Jawab sebelum waktu habis dan jangan biarkan cahaya terakhir padam.',
      };
    } else if (nama.contains('indonesia')) {
      return {
        'img': 'assets/dungeon/dungeon-crystal-orange.webp',
        'desc': 'Tata bahasa, kosakata, dan pemahaman bacaan di lorong yang berkilau dan makin gelap.',
      };
    } else if (nama.contains('inggris') || nama.contains('english')) {
      return {
        'img': 'assets/dungeon/dungeon-crystal-purple.webp',
        'desc': 'Vocabulary, grammar, dan reading. Satu jawaban salah, satu hati hilang.',
      };
    } else if (nama.contains('ips') || nama.contains('sosial')) {
      return {
        'img': 'assets/dungeon/dungeon-crystal-blue.webp',
        'desc': 'Sejarah, geografi, dan ekonomi menunggu di balik gerbang yang masih terkunci.',
      };
    } else if (nama.contains('pancasila') || nama.contains('pkn')) {
      return {
        'img': 'assets/dungeon/dungeon-door.webp',
        'desc': 'Uji integritas, wawasan kebangsaan, dan tekadmu menaklukkan lorong para ksatria.',
      };
    } else {
      const pool = [
        'assets/dungeon/dungeon-sunset-crags.webp',
        'assets/dungeon/dungeon-sunset-cave.webp',
        'assets/dungeon/dungeon-crystal-orange.webp',
        'assets/dungeon/dungeon-crystal-purple.webp',
        'assets/dungeon/dungeon-crystal-blue.webp',
        'assets/dungeon/dungeon-door.webp',
      ];
      return {
        'img': pool[index % pool.length],
        'desc': 'Taklukkan tantangan $namaMapel, raih multiplier tertinggi dan capai lantai terdalam!',
      };
    }
  }

  static Map<String, String> parseMapelNames(String namaMapel) {
    final nama = namaMapel.trim();
    final match = RegExp(r'^(.*?)\s*\(([^)]+)\)$').firstMatch(nama);
    if (match != null) {
      return {
        'short': match.group(2)!.trim(),
        'full': match.group(1)!.trim(),
      };
    }
    return {'short': nama, 'full': nama};
  }

  void _onStartPressed(Map<String, dynamic> activeItem) {
    final bool isUnlocked = activeItem['terbuka'] == true;
    final int idMapel = activeItem['id_mapel'] ?? 0;
    final String namaMapel = activeItem['nama_mapel'] ?? 'Dungeon';

    if (!isUnlocked) {
      final alasan = activeItem['alasan_terkunci'] ?? 'Dungeon ini belum memenuhi syarat untuk dimainkan.';
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF0F3A5F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFFDE68A), width: 1.5),
          ),
          content: Row(
            children: [
              const Icon(Icons.lock_rounded, color: Color(0xFFFDE68A), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  alasan,
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DungeonGameplayPage(
          idMapel: idMapel,
          namaMapel: namaMapel,
        ),
      ),
    ).then((_) {
      if (mounted) context.read<DungeonProvider>().fetchDungeons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dungeonProv = context.watch<DungeonProvider>();
    final bool isLoading = dungeonProv.isLoading;
    final String? errorMessage = dungeonProv.error;
    final List<Map<String, dynamic>> dungeons = dungeonProv.dungeons;
    final int activeIdx = dungeonProv.activeIdx;

    if (isLoading && dungeons.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A182E),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF1488E6)),
              SizedBox(height: 16),
              Text(
                'Memuat Gerbang Dungeon...',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null && dungeons.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A182E),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 52, color: Color(0xFFF43F5E)),
                const SizedBox(height: 14),
                Text(
                  'Gagal Membuka Dungeon',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.read<DungeonProvider>().fetchDungeons(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1488E6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (dungeons.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A182E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text(
            'Belum ada dungeon yang tersedia untuk jenjang Anda.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final activeItem = dungeons[activeIdx.clamp(0, dungeons.length - 1)];
    final activeMeta = getDungeonMeta(activeItem['nama_mapel'] ?? '', activeIdx);
    final activeNames = parseMapelNames(activeItem['nama_mapel'] ?? '');
    final bool isLocked = activeItem['terbuka'] != true;
    final bool hasActiveSession = activeItem['ada_sesi_aktif'] == true;
    final int rekorSkor = activeItem['rekor_skor'] ?? 0;
    final int lantai = activeItem['lantai_tertinggi'] ?? 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0A182E),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ===================================================================
          // 1. BACKGROUND DINAMIS SESUAI MAPEL YANG AKTIF
          // ===================================================================
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Image.asset(
              activeMeta['img'],
              key: ValueKey<String>(activeMeta['img']),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF0A182E)),
            ),
          ),

          // ===================================================================
          // 2. OVERLAY GRADIEN GELAP (Agar Teks & Tombol Kontras & Jelas)
          // ===================================================================
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.4, 0.85, 1.0],
                colors: [
                  Color(0xB3081C3C), // 70% dark navy top
                  Color(0x800A182E), // 50%
                  Color(0xF00A182E), // 94%
                  Color(0xFF071224), // 100% solid bottom
                ],
              ),
            ),
          ),

          // ===================================================================
          // 3. KONTEN UTAMA DUNGEON
          // ===================================================================
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Action Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tombol Kembali
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),

                      // Judul Header
                      Text(
                        'DUNGEON SOAL',
                        style: GoogleFonts.fredoka(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Colors.white,
                          shadows: const [
                            Shadow(color: Color(0xFF0B2447), blurRadius: 8, offset: Offset(0, 2)),
                          ],
                        ),
                      ),

                      // Tombol Riwayat Sesi
                      InkWell(
                        onTap: () {
                          // Menampilkan info riwayat singkat
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Riwayat dungeon dapat dilihat setelah permainan selesai.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('📜 ', style: TextStyle(fontSize: 12)),
                              Text(
                                'Riwayat',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // =============================================================
                // 4. BARIS TABS HORIZONTAL (Gaya Web Elearningarrava)
                // =============================================================
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: dungeons.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                    itemBuilder: (context, idx) {
                      final item = dungeons[idx];
                      final isSelected = idx == activeIdx;
                      final isTabLocked = item['terbuka'] != true;
                      final names = parseMapelNames(item['nama_mapel'] ?? '');
                      final meta = getDungeonMeta(item['nama_mapel'] ?? '', idx);

                      return GestureDetector(
                        onTap: () {
                          context.read<DungeonProvider>().setActiveIdx(idx);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Color(0xFF1488E6), Color(0xFF0B69C4)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  )
                                : null,
                            color: isSelected ? null : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF10315A),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10315A),
                                offset: Offset(0, isSelected ? 2 : 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          transform: Matrix4.translationValues(0, isSelected ? 2 : 0, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Teks Nama Mapel
                              Text(
                                names['short'] ?? '',
                                style: GoogleFonts.fredoka(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : const Color(0xFF10315A),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Thumbnail Mini
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  meta['img'],
                                  width: 26,
                                  height: 26,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                ),
                              ),
                              if (isTabLocked) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.lock_rounded,
                                  size: 14,
                                  color: Color(0xFF10315A),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Spacer(),

                // =============================================================
                // 5. HERO INFO AREA (Khas Dungeon Elearningarrava Web)
                // =============================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Judul Mapel Besar
                      Text(
                        activeNames['short'] ?? '',
                        style: GoogleFonts.fredoka(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          color: Colors.white,
                          shadows: const [
                            Shadow(color: Color(0xFF0B2447), blurRadius: 10, offset: Offset(0, 3)),
                          ],
                        ),
                      ),

                      if ((activeNames['full'] ?? '') != (activeNames['short'] ?? '')) ...[
                        const SizedBox(height: 4),
                        Text(
                          activeNames['full'] ?? '',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFBDE0FE),
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Status Jenjang / Syarat Gembok
                      if (isLocked)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade900.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFDE68A).withValues(alpha: 0.6)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock_outline_rounded, color: Color(0xFFFDE68A), size: 14),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  activeItem['alasan_terkunci'] ?? 'Belum dibuka · Syarat belum cukup',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFFDE68A),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const Row(
                          children: [
                            Icon(Icons.verified_rounded, color: Color(0xFF7DD3FC), size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Dungeon Siap Dijelajahi',
                              style: TextStyle(
                                color: Color(0xFFBAE6FD),
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 10),

                      // Deskripsi Suasana Dungeon
                      Text(
                        activeMeta['desc'],
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 13.5,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE2EDFF),
                          shadows: const [
                            Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 1)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // =======================================================
                      // 6. STAT PILLS (❤️ 3 Nyawa, ⚡ Multiplier, 🏆 Rekor, 🪜 Lantai)
                      // =======================================================
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildPill('❤️ 3 Nyawa', const Color(0xFFFF4D6D)),
                          _buildPill('⚡ Multiplier 3.0x', const Color(0xFF38BDF8)),
                          if (rekorSkor > 0)
                            _buildPill('🏆 Rekor: $rekorSkor', const Color(0xFFFBBF24)),
                          if (lantai > 1)
                            _buildPill('🪜 Lt. $lantai', const Color(0xFF34D399)),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // =======================================================
                      // 7. TOMBOL AKSI 3D UTAMA ("Mulai" / "Lanjutkan" / "Terkunci")
                      // =======================================================
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => _onStartPressed(activeItem),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLocked
                                ? const Color(0xFF334155)
                                : (hasActiveSession
                                    ? const Color(0xFF059669) // Emerald
                                    : const Color(0xFF0284C7)), // Sky Blue
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isLocked
                                    ? const Color(0xFF1E293B)
                                    : (hasActiveSession
                                        ? const Color(0xFF064E3B)
                                        : const Color(0xFF0369A1)),
                                width: 2.5,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isLocked
                                    ? Icons.lock_rounded
                                    : (hasActiveSession
                                        ? Icons.sports_kabaddi_rounded
                                        : Icons.play_arrow_rounded),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isLocked
                                    ? 'Terkunci'
                                    : (hasActiveSession
                                        ? 'Lanjutkan Petualangan'
                                        : 'Mulai Petualangan'),
                                style: GoogleFonts.fredoka(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String text, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: accentColor,
          fontWeight: FontWeight.w800,
          fontSize: 11.5,
        ),
      ),
    );
  }
}
