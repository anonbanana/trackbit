import 'package:flutter_test/flutter_test.dart';
import 'package:trackbit/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('required', () {
      test('returns error for empty string', () {
        expect(Validators.required(''), isNotNull);
        expect(Validators.required('  '), isNotNull);
        expect(Validators.required(null), isNotNull);
      });

      test('returns null for valid input', () {
        expect(Validators.required('hello'), isNull);
        expect(Validators.required(' a '), isNull);
      });
    });

    group('email', () {
      test('returns error for invalid emails', () {
        expect(Validators.email('notanemail'), isNotNull);
        expect(Validators.email('test@'), isNotNull);
        expect(Validators.email('@test.com'), isNotNull);
      });

      test('returns null for empty string (optional field)', () {
        expect(Validators.email(''), isNull);
        expect(Validators.email(null), isNull);
      });

      test('returns null for valid emails', () {
        expect(Validators.email('test@example.com'), isNull);
        expect(Validators.email('user.name@domain.co'), isNull);
      });
    });

    group('phone', () {
      test('returns error for invalid phones', () {
        expect(Validators.phone('abc'), isNotNull);
      });

      test('returns null for empty string (optional field)', () {
        expect(Validators.phone(''), isNull);
        expect(Validators.phone(null), isNull);
      });

      test('returns null for valid phones', () {
        expect(Validators.phone('1234567890'), isNull);
        expect(Validators.phone('+1234567890'), isNull);
      });
    });

    group('minLength', () {
      test('returns error for short strings', () {
        expect(Validators.minLength('ab', 3), isNotNull);
        expect(Validators.minLength('', 3), isNotNull);
      });

      test('returns null for strings meeting minimum', () {
        expect(Validators.minLength('abc', 3), isNull);
        expect(Validators.minLength('abcd', 3), isNull);
      });

      test('returns null for null input', () {
        expect(Validators.minLength(null, 3), isNull);
      });
    });

    group('positiveNumber', () {
      test('returns error for invalid or non-positive numbers', () {
        expect(Validators.positiveNumber('abc'), isNotNull);
        expect(Validators.positiveNumber('-1'), isNotNull);
      });

      test('returns null for empty string (optional field)', () {
        expect(Validators.positiveNumber(''), isNull);
        expect(Validators.positiveNumber(null), isNull);
      });

      test('returns null for positive numbers', () {
        expect(Validators.positiveNumber('1'), isNull);
        expect(Validators.positiveNumber('0.01'), isNull);
        expect(Validators.positiveNumber('100'), isNull);
      });
    });
  });
}
