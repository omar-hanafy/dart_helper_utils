import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Duration extensions', () {
    test('fromNow and ago are relative to now', () {
      final now = DateTime.now();
      final future = const Duration(milliseconds: 10).fromNow;
      final past = const Duration(milliseconds: 10).ago;
      expect(future.isAfter(now), isTrue);
      expect(past.isBefore(now), isTrue);
    });

    test('delayed runs computation', () async {
      final result = await const Duration(milliseconds: 1).delayed(() => 42);
      expect(result, 42);
    });
  });
}
