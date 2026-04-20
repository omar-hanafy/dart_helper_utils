import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('public exports', () {
    test('re-exports collection extensions and helpers', () {
      expect([1, 2, 3].firstOrNull, 1);
      expect(<int>[].firstOrNull, isNull);

      final grouped = groupBy(['ant', 'apple', 'bat'], (value) => value[0]);
      expect(grouped['a'], ['ant', 'apple']);
      expect(grouped['b'], ['bat']);
    });
  });
}
