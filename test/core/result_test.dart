import 'package:flutter_test/flutter_test.dart';
import 'package:trackbit/core/utils/result.dart';
import 'package:trackbit/core/errors/failure.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('holds data correctly', () {
        const result = Success(42);
        expect(result.data, 42);
      });

      test('when calls success callback', () {
        const result = Success('hello');
        final output = result.when(
          success: (d) => 'got: $d',
          error: (f) => 'error: ${f.message}',
        );
        expect(output, 'got: hello');
      });
    });

    group('Error', () {
      test('holds failure correctly', () {
        const failure = DatabaseFailure('db error');
        const result = Error(failure);
        expect(result.failure.message, 'db error');
      });

      test('when calls error callback', () {
        const failure = AuthFailure('auth failed');
        const result = Error(failure);
        final output = result.when(
          success: (d) => 'got: $d',
          error: (f) => 'error: ${f.message}',
        );
        expect(output, 'error: auth failed');
      });
    });

    group('Failure types', () {
      test('DatabaseFailure', () {
        const f = DatabaseFailure('msg', code: 'CODE');
        expect(f.message, 'msg');
        expect(f.code, 'CODE');
      });

      test('AuthFailure', () {
        const f = AuthFailure('auth err');
        expect(f.message, 'auth err');
        expect(f.code, isNull);
      });

      test('ValidationFailure', () {
        const f = ValidationFailure('validation err');
        expect(f.message, 'validation err');
      });

      test('SyncFailure', () {
        const f = SyncFailure('sync err');
        expect(f.message, 'sync err');
      });

      test('UnexpectedFailure', () {
        const f = UnexpectedFailure('unexpected');
        expect(f.message, 'unexpected');
      });

      test('equatable equality', () {
        const f1 = DatabaseFailure('msg', code: 'C');
        const f2 = DatabaseFailure('msg', code: 'C');
        expect(f1, equals(f2));
      });
    });
  });
}
