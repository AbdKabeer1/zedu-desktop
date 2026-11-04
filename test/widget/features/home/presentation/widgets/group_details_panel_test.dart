import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  Future<void> pumpPanel(WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestMaterialApp(
        Scaffold(
          body: GroupDetailsPanel(
            group: const GroupDM(id: 'group-1', name: 'Team', members: []),
            onClose: () {},
            onRename: (_) {},
            onLeave: () {},
          ),
        ),
      ),
    );
  }

  String? tooltipOf(WidgetTester tester, IconData icon) {
    final button = find.ancestor(
      of: find.byIcon(icon),
      matching: find.byType(IconButton),
    );
    return tester.widget<IconButton>(button).tooltip;
  }

  testWidgets('the close and edit buttons have tooltips', (tester) async {
    await pumpPanel(tester);

    expect(tooltipOf(tester, Icons.close), 'Close group details');
    expect(tooltipOf(tester, Icons.edit), 'Edit group name');
  });

  testWidgets('the save button has a tooltip while editing the name', (
    tester,
  ) async {
    await pumpPanel(tester);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pump();

    expect(tooltipOf(tester, Icons.check), 'Save group name');
  });
}
