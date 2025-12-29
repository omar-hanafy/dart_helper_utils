import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Num Extensions', () {
    test('toFileSize formats bytes', () {
      expect(1024.toFileSize(), '1.00 KB');
      expect((1024 * 1024).toFileSize(), '1.00 MB');
      expect(500.toFileSize(), '500.00 B');
    });
  });
}
