import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Duration extensions', () {
    test('fromNow and ago are relative to now', () {
      final now = DateTime.now();
      final future = const Duration(seconds: 1).fromNow;
      final past = const Duration(seconds: 1).ago;
      expect(
        future.difference(now),
        greaterThanOrEqualTo(const Duration(milliseconds: 900)),
      );
      expect(
        now.difference(past),
        greaterThanOrEqualTo(const Duration(milliseconds: 900)),
      );
    });

    test('delayed runs computation', () async {
      final result = await const Duration(milliseconds: 1).delayed(() => 42);
      expect(result, 42);
    });
  });
}
