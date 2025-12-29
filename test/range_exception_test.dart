import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('RException', () {
    test('toString includes message', () {
      const exception = RException('oops');
      expect(exception.toString(), 'RException: oops');
    });

    test('steps constructor sets default message', () {
      final exception = RException.steps();
      expect(exception.message, 'The range must be more than 0');
    });
  });
}
