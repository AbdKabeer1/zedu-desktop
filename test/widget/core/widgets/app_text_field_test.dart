import 'package:zedu/core/core.dart';

import '../../../helpers/helpers.dart';

void main() {
  testWidgets('error borders keep the 6px radius and error colour', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(
            controller: controller,
            hint: 'Email',
            validator: (value) => 'Required',
          ),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    final decoration = field.decoration!;
    final errorBorder = decoration.errorBorder! as OutlineInputBorder;
    final focusedErrorBorder =
        decoration.focusedErrorBorder! as OutlineInputBorder;

    expect(errorBorder.borderRadius, BorderRadius.circular(6));
    expect(errorBorder.borderSide.color, AppPalette.light.error);
    expect(focusedErrorBorder.borderRadius, BorderRadius.circular(6));
    expect(focusedErrorBorder.borderSide.color, AppPalette.light.error);
  });

  group('AppTextField error borders', () {
    testWidgets(
      'defines errorBorder and focusedErrorBorder with 6px radius and error color',
      (tester) async {
        await tester.pumpWidget(
          buildTestMaterialApp(
            Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(24),
                child: AppTextField(
                  controller: TextEditingController(),
                  hint: 'Email',
                  validator: (val) => 'Invalid email',
                ),
              ),
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        final decoration = textField.decoration;
        expect(decoration, isNotNull);

        final errorBorder = decoration?.errorBorder as OutlineInputBorder?;
        expect(errorBorder, isNotNull);
        expect(errorBorder?.borderRadius, BorderRadius.circular(6));
        expect(errorBorder?.borderSide.color, AppPalette.light.error);

        final focusedErrorBorder =
            decoration?.focusedErrorBorder as OutlineInputBorder?;
        expect(focusedErrorBorder, isNotNull);
        expect(focusedErrorBorder?.borderRadius, BorderRadius.circular(6));
        expect(focusedErrorBorder?.borderSide.color, AppPalette.light.error);
      },
    );
  });
}
