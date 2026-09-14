import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/utils/validators.dart';

void main() {
  group('validateEmail', () {
    test('accepts an email with surrounding spaces', () {
      expect(Validators.validateEmail('  person@example.com  '), isNull);
    });

    test('rejects an email with an internal space', () {
      expect(
        Validators.validateEmail('person @example.com'),
        'Ingresa un email válido',
      );
    });

    test('treats whitespace-only input as empty', () {
      expect(
        Validators.validateEmail('   '),
        'Por favor ingresa tu email',
      );
    });
  });
}
