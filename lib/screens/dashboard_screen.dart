import 'package:flutter/material.dart';
import '../shared/widgets/headers/app_header.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Media Query
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 32.0 : 20.0;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panggil Header yang dipisah
            const AppHeader(
              name: 'Admin',
              subtitle: 'Kelola platform dengan mudah',
            ),
            const SizedBox(height: 24),

            // Kartu Metrik (LayoutBuilder)
            _buildMetricsGrid(),
            const SizedBox(height: 24),

            // Grafik Aktivitas
            _buildPlatformActivityCard(),
            const SizedBox(height: 24),

            // Top Mata Pelajaran (LayoutBuilder di progress bar)
            _buildTopSubjectsCard(),
          ],
        ),
      ),
    );
  }

  // Method-method pendukung tetap di dalam file ini karena Anda tidak ingin memisahkannya ke banyak file
  Widget _buildMetricsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 550;
        return GridView.count(
          crossAxisCount: isWide ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isWide ? 1.5 : 1.35,
          children: const [
            _CardItem(title: 'Siswa', value: '1,248', icon: Icons.people_outline),
            _CardItem(title: 'Murid', value: '156', icon: Icons.menu_book_outlined),
            _CardItem(title: 'Soal', value: '2,450', icon: Icons.edit_outlined),
            _CardItem(title: 'Quiz', value: '23', icon: Icons.star_outline_rounded),
          ],
        );
      },
    );
  }

  Widget _buildPlatformActivityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E9F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Aktivitas Platform', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            width: double.infinity,
            child: CustomPaint(painter: _ChartPainter()),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSubjectsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E9F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Top Mata Pelajaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          _SubjectProgress(title: 'Matematika', percentage: 92),
          SizedBox(height: 14),
          _SubjectProgress(title: 'Bahasa Inggris', percentage: 78),
          SizedBox(height: 14),
          _SubjectProgress(title: 'IPA', percentage: 65),
          SizedBox(height: 14),
          _SubjectProgress(title: 'IPS', percentage: 60),
        ],
      ),
    );
  }
}

// Widget internal kartu
class _CardItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _CardItem({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF7A869A))),
              Icon(icon, size: 18, color: const Color(0xFF2F66EE)),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Widget internal progress bar dengan LayoutBuilder
class _SubjectProgress extends StatelessWidget {
  final String title;
  final int percentage;

  const _SubjectProgress({required this.title, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('$percentage%', style: const TextStyle(color: Color(0xFF2F66EE), fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(height: 8, width: constraints.maxWidth, decoration: BoxDecoration(color: const Color(0xFFF0F4FA), borderRadius: BorderRadius.circular(4))),
                Container(height: 8, width: (percentage / 100) * constraints.maxWidth, decoration: BoxDecoration(color: const Color(0xFF2F66EE), borderRadius: BorderRadius.circular(4))),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dashedPaint = Paint()..color = const Color(0xFFDDE3EC)..strokeWidth = 1.0..style = PaintingStyle.stroke;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height * 0.55), Offset(startX + 4, size.height * 0.55), dashedPaint);
      startX += 8;
    }

    final linePaint = Paint()..color = const Color(0xFF2F66EE)..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final path = Path();
    final points = [
      Offset(0, size.height * 0.72),
      Offset(size.width * 0.15, size.height * 0.60),
      Offset(size.width * 0.28, size.height * 0.70),
      Offset(size.width * 0.42, size.height * 0.52),
      Offset(size.width * 0.55, size.height * 0.58),
      Offset(size.width * 0.70, size.height * 0.45),
      Offset(size.width * 0.85, size.height * 0.48),
      Offset(size.width * 1.0, size.height * 0.20),
    ];
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}