import 'package:zedu/core/core.dart';
import '../../../helpers/helpers.dart';

void main() {
  group('AppTextField password visibility toggle', () {
    testWidgets('labels the toggle with the action it performs', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        buildTestMaterialApp(
          Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: AppTextField(
                controller: TextEditingController(text: 'secret123'),
                hint: 'Password',
                isPassword: true,
              ),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Show password'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Hide password'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      semantics.dispose();
    });
  });

  group('AppTextField error borders', () {
    Matcher sixPxErrorBorder(Color color) => isA<OutlineInputBorder>()
        .having((b) => b.borderRadius, 'borderRadius', BorderRadius.circular(6))
        .having((b) => b.borderSide.color, 'colour', color);

    Future<InputDecorator> pumpAndValidate(WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        buildTestMaterialApp(
          Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: AppTextField(
                  controller: TextEditingController(),
                  hint: 'Email',
                  validator: (value) => 'Required',
                ),
              ),
            ),
          ),
        ),
      );
      formKey.currentState!.validate();
      await tester.pump();
      return tester.widget<InputDecorator>(find.byType(InputDecorator));
    }

    testWidgets('keeps the 6px radius and theme colour when validation fails', (
      tester,
    ) async {
      await pumpAndValidate(tester);
      final colors = tester.element(find.byType(InputDecorator)).colors;

      expect(find.text('Required'), findsOneWidget);
      final decorator = tester.widget<InputDecorator>(
        find.byType(InputDecorator),
      );
      expect(decorator.decoration.errorBorder, sixPxErrorBorder(colors.error));
      expect(
        decorator.decoration.focusedErrorBorder,
        sixPxErrorBorder(colors.error),
      );
    });

    testWidgets('declares error borders instead of falling back to defaults', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestMaterialApp(
          Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: AppTextField(
                controller: TextEditingController(),
                hint: 'Email',
              ),
            ),
          ),
        ),
      );

      final decoration = tester
          .widget<TextField>(find.byType(TextField))
          .decoration!;
      expect(decoration.errorBorder, isNotNull);
      expect(decoration.focusedErrorBorder, isNotNull);
    });
  });
}
