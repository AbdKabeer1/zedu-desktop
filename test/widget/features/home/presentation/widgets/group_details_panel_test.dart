import 'package:zedu/features/features.dart';
import '../../../../../helpers/helpers.dart';

TeamMember member({required String id, String? name, String email = ''}) {
  return TeamMember(
    id: id,
    email: email,
    role: 'member',
    dateJoined: '2026-11-01',
    status: TeamMemberStatus.active,
    name: name,
  );
}

Future<void> pumpPanel(WidgetTester tester, List<TeamMember> members) {
  return tester.pumpWidget(
    buildTestMaterialApp(
      Scaffold(
        body: GroupDetailsPanel(
          group: GroupDM(id: 'group-1', name: 'Design', members: members),
          onClose: () {},
          onRename: (_) {},
          onLeave: () {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('member avatars never crash on empty or padded names', (
    tester,
  ) async {
    await pumpPanel(tester, [
      member(id: 'a', name: '', email: 'mo@zedu.chat'),
      member(id: 'b', name: ' john'),
      member(id: 'c', name: '   ', email: '  '),
    ]);

    expect(tester.takeException(), isNull);
    expect(find.text('M'), findsOneWidget);
    expect(find.text('J'), findsOneWidget);
    expect(find.text('?'), findsOneWidget);
  });
}
