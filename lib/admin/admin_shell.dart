import 'package:flutter/material.dart';

import 'teachers/teacher_page.dart';
import 'modules/module_page.dart';
import '../shared/widgets/app_bottom_navigation.dart';
import 'dashboard/admin_dashboard_page.dart';
import 'students/student_page.dart';
import 'quizzes/quiz_menu_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentPage(),

      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const AdminDashboardPage();

      case 1:
        return const ModulePage();

      case 2:
        return const TeacherPage();

      case 3:
        return const StudentPage();

      case 4:
        return const QuizMenuPage();

      default:
        return const AdminDashboardPage();
    }
  }
}
