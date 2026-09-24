import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _accent = Color(0xFF5B5FEF);

  static const List<Map<String, dynamic>> _dummyModul = [
    {'judul': 'Matematika Dasar', 'jenjang': 'SD', 'icon': Icons.calculate},
    {'judul': 'Bahasa Indonesia', 'jenjang': 'SD', 'icon': Icons.menu_book},
    {'judul': 'IPA Terpadu', 'jenjang': 'SMP', 'icon': Icons.science},
    {'judul': 'Bahasa Inggris', 'jenjang': 'SMP', 'icon': Icons.language},
    {'judul': 'Fisika', 'jenjang': 'SMA', 'icon': Icons.bolt},
    {'judul': 'Kimia', 'jenjang': 'SMA', 'icon': Icons.biotech},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),

      // biar isi ga nabrak sm status bar HP
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            int jumlahKolom;

            // HP kecil = 2 kolom
            if (constraints.maxWidth < 500) {
              jumlahKolom = 2;

              // kalau agak lebar = 3 kolom
            } else if (constraints.maxWidth < 900) {
              jumlahKolom = 3;

              // kalau layarnya gede = 4 kolom
            } else {
              jumlahKolom = 4;
            }

            return Padding(
              // kasih jarak dari pinggir layar
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: _accent.withValues(alpha: 0.1),
                        child: const Icon(Icons.person, color: _accent),
                      ),

                      const SizedBox(width: 12),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, Siswa 👋',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),

                          Text(
                            'Pilih modul belajar',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // expanded biar GridView ngisi sisa layar
                  Expanded(
                    child: GridView.builder(
                      // ngatur tampilan grid
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        // jumlah card dalam satu baris
                        crossAxisCount: jumlahKolom,

                        // jarak antar card
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,

                        // ngatur ukuran card
                        childAspectRatio: 0.95,
                      ),

                      // jumlah card ngikut jumlah modul
                      itemCount: _dummyModul.length,

                      // bikin card satu-satu
                      itemBuilder: (context, index) {
                        // ambil data sesuai index
                        final modul = _dummyModul[index];

                        return _ModulCard(
                          judul: modul['judul'] as String,
                          jenjang: modul['jenjang'] as String,
                          icon: modul['icon'] as IconData,

                          onTap: () {
                        
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Buka modul: ${modul['judul']}'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ModulCard extends StatelessWidget {
  final String judul;
  final String jenjang;
  final IconData icon;
  final VoidCallback onTap;

  const _ModulCard({
    required this.judul,
    required this.jenjang,
    required this.icon,
    required this.onTap,
  });

  static const _accent = Color(0xFF5B5FEF);

  @override
  Widget build(BuildContext context) {
    // InkWell biar card bs diklik
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),

      child: Container(
        padding: const EdgeInsets.all(16),

        // tampilan card
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 26, color: _accent),
            ),

            const Spacer(),

            Text(
              judul,
              maxLines: 2,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),

            const SizedBox(height: 6),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                jenjang,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
