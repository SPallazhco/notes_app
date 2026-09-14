import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/widgets/custom_text_tield.dart';

void main() {
  testWidgets('email field removes surrounding whitespace from the keyboard',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            icon: Icons.email,
            labelText: 'Email',
            controller: controller,
            isEmail: true,
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField),
      ' person@example.com ',
    );

    expect(controller.text, 'person@example.com');
  });

  testWidgets('email field preserves internal whitespace for validation',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            icon: Icons.email,
            labelText: 'Email',
            controller: controller,
            isEmail: true,
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField),
      'person @example.com',
    );

    expect(controller.text, 'person @example.com');
  });

  testWidgets('email field uses email-specific input settings', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            icon: Icons.email,
            labelText: 'Email',
            isEmail: true,
          ),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));

    expect(field.keyboardType, TextInputType.emailAddress);
    expect(field.autofillHints, contains(AutofillHints.email));
    expect(field.autocorrect, isFalse);
    expect(field.enableSuggestions, isFalse);
    expect(field.textCapitalization, TextCapitalization.none);
  });
}
