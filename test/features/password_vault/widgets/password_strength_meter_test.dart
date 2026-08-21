import 'package:flutter_test/flutter_test.dart';
import 'package:optisec_mobile/features/password_vault/widgets/password_strength_meter.dart';

void main() {
  group('PasswordStrengthMeter.describe (default, generic heuristic)', () {
    test('9-char password with all 4 char classes is reported Strong', () {
      // Regression guard: default mode must keep its existing behavior
      // for master-password / entry-password screens, which only require
      // 8 chars natively.
      final result = PasswordStrengthMeter.describe('Abcdefg1!');
      expect(result.label, 'Strong');
      expect(result.fraction, 1.0);
    });
  });

  group('PasswordStrengthMeter.describe (strict, matches native export check)', () {
    test(
        '9-char password with all 4 char classes is NOT Strong '
        '(native requires >=10 chars, would reject with WEAK_EXPORT_PASSWORD)',
        () {
      final result = PasswordStrengthMeter.describe('Abcdefg1!', strict: true);
      expect(result.label, isNot('Strong'));
      expect(result.fraction, lessThan(1.0));
    });

    test('10-char password with 3 char classes is Strong (native accepts it)', () {
      final result = PasswordStrengthMeter.describe('Abcdefghi1', strict: true);
      expect(result.label, 'Strong');
      expect(result.fraction, 1.0);
    });

    test('10-char password with only 2 char classes is NOT Strong', () {
      final result = PasswordStrengthMeter.describe('abcdefghij', strict: true);
      expect(result.label, isNot('Strong'));
    });

    test('empty password is Very weak', () {
      final result = PasswordStrengthMeter.describe('', strict: true);
      expect(result.label, 'Very weak');
    });
  });
}
