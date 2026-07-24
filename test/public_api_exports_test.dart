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

    test('re-exports stringo string extensions', () {
      // These members moved to the `stringo` package in 6.1.0. They must stay
      // reachable from the `dart_helper_utils` import alone, with no extra
      // dependency or import, or the extraction is a breaking change.
      expect('hello_world'.toCamelCase, 'helloWorld');
      expect('helloWorld'.toSnakeCase, 'hello_world');
      expect('Hello, World!'.slugify(), 'hello-world');
      expect('Hello World'.truncate(5), 'Hello...');
      expect('   '.isBlank, isTrue);
      expect('12345'.isNumeric, isTrue);
      expect(RegExp(regexNumeric).hasMatch('42'), isTrue);
    });

    test('domain validators stay in dart_helper_utils', () {
      // The other half of the 6.1.0 split: these did NOT move, and must not be
      // defined in both packages (that would be an ambiguous-extension error).
      expect('test@email.com'.isValidEmail, isTrue);
      expect('123e4567-e89b-12d3-a456-426614174000'.isUuid, isTrue);
      expect('192.168.1.1'.isValidIp4, isTrue);
      expect('report.pdf'.isPDF, isTrue);
      expect('1:30'.parseDuration(), const Duration(minutes: 1, seconds: 30));
    });
  });
}
