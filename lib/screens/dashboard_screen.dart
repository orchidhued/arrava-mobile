import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF10B981);
  static const _orange = Color(0xFFF59E0B);
  static const _purple = Color(0xFF8B5CF6);

  static const List<Map<String, dynamic>> _materiHariIni = [
    {'label': 'Matematika', 'icon': Icons.calculate, 'color': _blue},
    {'label': 'B. Inggris', 'icon': Icons.language, 'color': _purple},
    {'label': 'IPAS', 'icon': Icons.public, 'color': _green},
    {'label': 'Seni Musik', 'icon': Icons.star_border, 'color': _orange},
  ];

  static const List<Map<String, dynamic>> _riwayatBelajar = [
    {
      'judul': 'Matematika - Bab 1',
      'tanggal': '2 hari lalu',
      'skor': '90',
      'icon': Icons.calculate,
      'color': _blue,
    },
    {
      'judul': 'B. Inggris - Vocabulary',
      'tanggal': '3 hari lalu',
      'skor': '85',
      'icon': Icons.language,
      'color': _purple,
    },
    {
      'judul': 'IPAS - Ekosistem',
      'tanggal': '5 hari lalu',
      'skor': '78',
      'icon': Icons.public,
      'color': _green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // ambil lebar layar buat ngatur jarak kiri-kanan & jumlah kolom grid
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
            
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFFDCE3FF),
                        child: Icon(Icons.person, color: _blue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, Eve!',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Semangat terus belajarnya!',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '🔥 7 Hari',
                          style: TextStyle(
                            color: _green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '12',
                          label: 'Kursus Aktif',
                          color: _blue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          value: '87%',
                          label: 'Progress',
                          color: _green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          value: '1,250',
                          label: 'Total XP',
                          color: _orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Lanjutkan Belajar',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.menu_book, color: _blue),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Matematika - Kelas 4',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Bab 2: Penjumlahan & Pengurangan',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progres Belajar',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              '65%',
                              style: TextStyle(
                                fontSize: 12,
                                color: _blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: 0.65,
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            color: _blue,
                          ),
                        ),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue.withOpacity(0.1),
                              foregroundColor: _blue,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Lanjutkan Belajar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Materi Hari Ini',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      // jumlah kolom ngikut hasil hitungan LayoutBuilder di atas
                      crossAxisCount: jumlahKolom,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.4,
                    ),
                    itemCount: _materiHariIni.length,
                    itemBuilder: (context, index) {
                      final materi = _materiHariIni[index];
                      return _MateriCard(
                        label: materi['label'] as String,
                        icon: materi['icon'] as IconData,
                        color: materi['color'] as Color,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Riwayat Belajar',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  // shrinkWrap + physics sama alasannya kaya di GridView:
                  // biar ListView ini nggak ikut discroll sendiri, karena
                  // udah ada scroll global dari SingleChildScrollView di atas
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _riwayatBelajar.length,
                    itemBuilder: (context, index) {
                      final riwayat = _riwayatBelajar[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == _riwayatBelajar.length - 1 ? 0 : 10,
                        ),
                        child: _RiwayatItem(
                          judul: riwayat['judul'] as String,
                          tanggal: riwayat['tanggal'] as String,
                          skor: riwayat['skor'] as String,
                          icon: riwayat['icon'] as IconData,
                          color: riwayat['color'] as Color,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),

      // BottomNavigationBar itu widget bawaan Flutter, tinggal kasih daftar item.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: _blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Belajar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_outlined),
            label: 'Latihan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// kartu kecil buat nampilin satu angka statistik (dipake 3x di atas)
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// baris kecil buat satu item di ListView "Riwayat Belajar"
class _RiwayatItem extends StatelessWidget {
  final String judul;
  final String tanggal;
  final String skor;
  final IconData icon;
  final Color color;

  const _RiwayatItem({
    required this.judul,
    required this.tanggal,
    required this.skor,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tanggal,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            'Skor $skor',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// card kecil buat satu mata pelajaran di grid "Materi Hari Ini"
class _MateriCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _MateriCard({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
