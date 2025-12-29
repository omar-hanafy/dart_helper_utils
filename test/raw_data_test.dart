import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Raw data constants', () {
    test('weekday and month maps have expected entries', () {
      expect(smallWeekdays[1], 'Mon');
      expect(fullWeekdays[7], 'Sunday');
      expect(smallMonthsNames[1], 'Jan');
      expect(fullMonthsNames[12], 'December');
    });

    test('duration and millisecond constants', () {
      expect(oneSecond, const Duration(seconds: 1));
      expect(oneMinute, const Duration(minutes: 1));
      expect(millisecondsPerSecond, 1000);
      expect(millisecondsPerDay, 24 * 60 * 60 * 1000);
    });

    test('regex constants match expected values', () {
      expect(RegExp(regexValidHexColor).hasMatch('#fff'), isTrue);
      expect(RegExp(regexValidHexColor).hasMatch('0xFF00FF'), isFalse);
      expect(RegExp(regexNumeric).hasMatch('123'), isTrue);
      expect(RegExp(regexAlphabet).hasMatch('abcDEF'), isTrue);
    });

    test('http status maps include known codes', () {
      expect(httpStatusMessages[200], 'OK');
      expect(httpStatusUserMessage[404], isNotEmpty);
      expect(httpStatusDevMessage[500], isNotEmpty);
    });
  });
}
