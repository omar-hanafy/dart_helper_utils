import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Duration formatting', () {
    test('toClockString formats as HH:mm:ss', () {
      const duration = Duration(hours: 1, minutes: 2, seconds: 3);
      expect(duration.toClockString(), '01:02:03');
    });

    test('toClockString uses total hours', () {
      const duration = Duration(hours: 27, minutes: 5, seconds: 9);
      expect(duration.toClockString(), '27:05:09');
    });

    test('toHumanShort formats as short text', () {
      const duration = Duration(hours: 1, minutes: 3, seconds: 4);
      expect(duration.toHumanShort(), '1h 3m 4s');
    });

    test('toHumanShort includes days when present', () {
      const duration = Duration(days: 2, hours: 1);
      expect(duration.toHumanShort(), '2d 1h');
    });

    test('toHumanShort returns 0s for zero', () {
      const duration = Duration.zero;
      expect(duration.toHumanShort(), '0s');
    });

    test('toClockString supports negatives', () {
      const duration = Duration(hours: -1, minutes: -2, seconds: -3);
      expect(duration.toClockString(), '-01:02:03');
    });

    test('toHumanShort supports negatives', () {
      const duration = Duration(minutes: -5, seconds: -10);
      expect(duration.toHumanShort(), '-5m 10s');
    });
  });

  group('Duration parsing', () {
    test('parses token format with spaces', () {
      expect('1h 20m'.parseDuration(), const Duration(hours: 1, minutes: 20));
    });

    test('parses token format without spaces', () {
      expect(
        '2d3h4m5s'.parseDuration(),
        const Duration(days: 2, hours: 3, minutes: 4, seconds: 5),
      );
    });

    test('parses minutes only', () {
      expect('45m'.parseDuration(), const Duration(minutes: 45));
    });

    test('parses clock format with hours', () {
      expect(
        '01:02:03'.parseDuration(),
        const Duration(hours: 1, minutes: 2, seconds: 3),
      );
    });

    test('parses clock format without hours', () {
      expect(
        '00:01:30'.parseDuration(),
        const Duration(minutes: 1, seconds: 30),
      );
    });

    test('parses clock format with large minutes', () {
      expect('90:00'.parseDuration(), const Duration(minutes: 90));
    });

    test('parses negative durations', () {
      expect(
        '-1h 20m'.parseDuration(),
        const Duration(hours: -1, minutes: -20),
      );
    });

    test('throws on empty input', () {
      expect(() => ''.parseDuration(), throwsFormatException);
    });

    test('throws on invalid token format', () {
      expect(() => '1h 20'.parseDuration(), throwsFormatException);
    });

    test('throws on invalid clock format', () {
      expect(() => '00:61:00'.parseDuration(), throwsFormatException);
    });
  });
}
