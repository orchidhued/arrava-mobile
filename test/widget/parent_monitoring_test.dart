import 'package:arrava_mobile/parent/children/parent_child_card.dart';
import 'package:arrava_mobile/parent/monitoring/parent_monitoring_menu.dart';
import 'package:arrava_mobile/parent/monitoring/parent_monitoring_page.dart';
import 'package:arrava_mobile/shared/widgets/app_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Monitoring shows API progress and opens every menu on mobile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const student = {'nama': 'Dina', 'jenjang': 'SMP', 'nisn': '123'};
    ParentMonitoringMenu? openedMenu;
    int? openedTab;
    var changeChildRequested = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ParentMonitoringPage(
              childCard: ParentChildCard(
                student: student,
                onChange: () => changeChildRequested = true,
              ),
              student: student,
              stats: const {
                'modul_selesai': 3,
                'total_modul': 4,
                'total_quiz_dikerjakan': 5,
                'avg_nilai': 88.5,
              },
              onOpenMenu: (menu) => openedMenu = menu,
            ),
          ),
          bottomNavigationBar: AppBottomNavigation.parent(
            currentIndex: 2,
            onTap: (index) => openedTab = index,
          ),
        ),
      ),
    );

    expect(find.text('Dina'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('3 dari 4 modul telah tuntas.'), findsOneWidget);
    await tester.tap(find.text('Ubah'));
    expect(changeChildRequested, isTrue);

    for (final menu in ParentMonitoringMenu.values) {
      final tile = find.text(menu.title);
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      expect(openedMenu, menu);
    }

    for (final (index, label) in [
      (0, 'Beranda'),
      (1, 'Anak Saya'),
      (2, 'Monitoring'),
      (3, 'Profil'),
    ]) {
      await tester.tap(find.text(label));
      expect(openedTab, index);
    }

    expect(tester.takeException(), isNull);
  });
}
