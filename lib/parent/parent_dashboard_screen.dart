import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/storage/secure_storage.dart';
import '../core/theme/app_colors.dart';
import '../providers/notification_provider.dart';
import '../services/dashboard_service.dart';
import '../shared/widgets/app_bottom_navigation.dart';
import '../shared/widgets/app_header.dart';
import '../shared/widgets/tween_float_background.dart';
import 'children/parent_child_card.dart';
import 'children/parent_children_page.dart';
import 'dashboard/parent_home_page.dart';
import 'monitoring/parent_monitoring_detail.dart';
import 'monitoring/parent_monitoring_menu.dart';
import 'monitoring/parent_monitoring_page.dart';
import 'profile/parent_profile_page.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final _scrollController = ScrollController();
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _hasError = false;
  String _parentName = 'Orang Tua / Wali';
  String _parentEmail = '';
  Map<String, dynamic> _dashboardData = {};
  int? _requestedStudentId;
  ParentMonitoringMenu? _activeMenu;

  List<Map<String, dynamic>> get _children =>
      (_dashboardData['children'] as List?)?.cast<Map<String, dynamic>>() ?? [];

  Map<String, dynamic>? get _selectedStudent =>
      _dashboardData['selected_student'] as Map<String, dynamic>?;

  int? get _selectedStudentId =>
      int.tryParse(_selectedStudent?['id_user']?.toString() ?? '');

  Map<String, dynamic> get _stats =>
      _dashboardData['stats'] as Map<String, dynamic>? ?? {};

  List<Map<String, dynamic>> get _activities =>
      (_dashboardData['recent_activities'] as List?)
          ?.cast<Map<String, dynamic>>() ??
      [];

  List<Map<String, dynamic>> get _achievements =>
      (_dashboardData['achievements'] as List?)?.cast<Map<String, dynamic>>() ??
      [];

  @override
  void initState() {
    super.initState();
    _loadIdentity();
    _loadParentData();
    context.read<NotificationProvider>().fetchNotifications(silent: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadIdentity() async {
    final name = await SecureStorage.read('user_name');
    final email = await SecureStorage.read('user_email');
    if (!mounted) return;
    setState(() {
      if (name != null && name.trim().isNotEmpty) _parentName = name.trim();
      _parentEmail = email?.trim() ?? '';
    });
  }

  Future<void> _loadParentData({int? studentId}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _requestedStudentId =
          studentId ?? _requestedStudentId ?? _selectedStudentId;
    });
    try {
      final data = await DashboardService.fetchParentDashboard(
        studentId: _requestedStudentId,
      );
      if (data.isEmpty) throw StateError('Dasbor orang tua kosong.');
      if (!mounted) return;
      setState(() {
        _dashboardData = data;
        _requestedStudentId = null;
      });
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  void _openTab(int index, {ParentMonitoringMenu? menu}) {
    _scrollToTop();
    setState(() {
      _currentIndex = index;
      _activeMenu = menu;
    });
    if (menu == ParentMonitoringMenu.attendance) {
      context.read<NotificationProvider>().fetchNotifications();
    }
  }

  Future<void> _changeStudent() async {
    final children = _children;
    final selectedId = _selectedStudentId;
    final id = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Pilih anak')),
            for (final student in children)
              ListTile(
                leading: ParentChildAvatar(student: student),
                title: Text(student['nama']?.toString() ?? 'Ananda'),
                selected:
                    student['id_user']?.toString() == selectedId.toString(),
                onTap: () => Navigator.pop(
                  sheetContext,
                  int.tryParse(student['id_user']?.toString() ?? ''),
                ),
              ),
          ],
        ),
      ),
    );
    if (mounted && id != null && id != selectedId) {
      await _loadParentData(studentId: id);
    }
  }

  Widget _buildChildCard() {
    final selected = _selectedStudent;
    if (selected == null) return const ParentNoChildCard();

    final photo = _children
        .where(
          (student) =>
              student['id_user'].toString() == _selectedStudentId.toString(),
        )
        .firstOrNull?['foto_profil'];
    return ParentChildCard(
      student: {...selected, 'foto_profil': selected['foto_profil'] ?? photo},
      onChange: _children.length > 1 ? _changeStudent : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _activeMenu == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _activeMenu != null) _openTab(2);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppHeader(
                title: 'Orang Tua',
                profileEnabled: _currentIndex != 3,
                onProfileTap: () => _openTab(3),
              ),
              Expanded(
                child: TweenFloatBackground(
                  scrollController: _scrollController,
                  child: _currentIndex == 3
                      ? Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 620),
                            child: ParentProfilePage(
                              name: _parentName,
                              email: _parentEmail,
                              onSaved: (profile) {
                                if (!mounted) return;
                                setState(() {
                                  _parentName = profile.name;
                                  _parentEmail = profile.email;
                                });
                              },
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadParentData,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 620),
                              child: ListView(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  24,
                                ),
                                children: [_buildCurrentTab()],
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNavigation.parent(
          currentIndex: _currentIndex,
          onTap: (index) => _openTab(index),
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Data anak gagal dimuat.'),
              TextButton(
                onPressed: _loadParentData,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    switch (_currentIndex) {
      case 1:
        return ParentChildrenPage(
          children: _children,
          selectedStudentId: _selectedStudentId,
          onSelect: (id) => _loadParentData(studentId: id),
          onOpenMonitoring: () => _openTab(2),
        );
      case 2:
        final menu = _activeMenu;
        final student = _selectedStudent;
        if (menu != null && student != null) {
          return ParentMonitoringDetail(
            menu: menu,
            student: student,
            stats: _stats,
            activities: _activities,
            achievements: _achievements,
            onBack: () => _openTab(2),
          );
        }
        return ParentMonitoringPage(
          childCard: _buildChildCard(),
          student: student,
          stats: _stats,
          onOpenMenu: (menu) => _openTab(2, menu: menu),
        );
      default:
        return ParentHomePage(
          parentName: _parentName,
          childCard: _buildChildCard(),
          selectedStudent: _selectedStudent,
          stats: _stats,
          activities: _activities,
          achievements: _achievements,
          onOpenMonitoring: (menu) => _openTab(2, menu: menu),
        );
    }
  }
}
