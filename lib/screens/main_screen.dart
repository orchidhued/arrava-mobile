import 'package:flutter/material.dart';
import '../shared/widgets/navigation/app_bottom_nav_bar.dart';
import 'dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(), // Tab 0: Dashboard Beranda
    Center(child: Text('Halaman Kelola Siswa')),
    Center(child: Text('Halaman Kelola Modul')),
    Center(child: Text('Halaman Bank Soal')),
    Center(child: Text('Halaman Quiz & Ujian')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}