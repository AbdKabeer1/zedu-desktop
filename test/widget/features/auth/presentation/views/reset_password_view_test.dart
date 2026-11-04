import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';
import 'package:zedu/features/auth/presentation/views/reset_password_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import '../../../../../helpers/helpers.dart';

// Fake notifier that avoids GetIt/locator setup while remaining type-compatible
// with authNotifierProvider (which is NotifierProvider<AuthNotifier, AuthState>).
class FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(status: AuthStatus.unauthenticated);
}

Widget buildResetPasswordViewUnderTest() {
  return ProviderScope(
    overrides: [authNotifierProvider.overrideWith(() => FakeAuthNotifier())],
    child: const MaterialApp(home: ResetPasswordView(email: 'user@example.com')),
  );
}

EditableText _editableTextOf(WidgetTester tester, Finder formFieldFinder) {
  return tester.widget<EditableText>(
    find.descendant(
      of: formFieldFinder,
      matching: find.byType(EditableText),
    ),
  );
}

void main() {
  group('ResetPasswordView', () {
    testWidgets('renders reset password heading and OTP inputs', (
      tester,
    ) async {
      await tester.pumpWidget(buildResetPasswordViewUnderTest());
      await tester.pump();

      expect(find.text('Enter verification code'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(8));
    });

    testWidgets('moves focus forward when entering OTP digits', (
      tester,
    ) async {
      await tester.pumpWidget(buildResetPasswordViewUnderTest());
      await tester.pump();

      // Type in first OTP field - focus should advance to second
      await tester.enterText(find.byType(TextFormField).first, '1');
      await tester.pump();

      final secondEditableText = _editableTextOf(
        tester,
        find.byType(TextFormField).at(1),
      );
      expect(FocusManager.instance.primaryFocus, secondEditableText.focusNode);
    });

    testWidgets('moves focus back when clearing an OTP field', (
      tester,
    ) async {
      await tester.pumpWidget(buildResetPasswordViewUnderTest());
      await tester.pump();

      // Enter digit in second field - focus advances to third
      await tester.enterText(find.byType(TextFormField).at(1), '5');
      await tester.pump();

      // Clear the second field using enterText with empty string
      await tester.enterText(find.byType(TextFormField).at(1), '');
      await tester.pump();

      final firstEditableText = _editableTextOf(
        tester,
        find.byType(TextFormField).first,
      );
      expect(FocusManager.instance.primaryFocus, firstEditableText.focusNode);
    });
  });
}
