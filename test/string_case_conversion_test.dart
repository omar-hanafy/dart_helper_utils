import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('String case conversions', () {
    test('toWords splits tokens', () {
      expect('helloWorld_example-Text'.toWords, [
        'hello',
        'World',
        'example',
        'Text',
      ]);
    });

    test('toCamelCase converts correctly', () {
      expect('hello_world'.toCamelCase, 'helloWorld');
    });

    test('toPascalCase converts correctly', () {
      expect('hello_world'.toPascalCase, 'HelloWorld');
    });

    test('toSnakeCase converts correctly', () {
      expect('helloWorld'.toSnakeCase, 'hello_world');
    });

    test('toKebabCase converts correctly', () {
      expect('helloWorld'.toKebabCase, 'hello-world');
    });

    test('capitalize helpers', () {
      expect('dart'.capitalizeFirstLetter, 'Dart');
      expect('DART'.capitalizeFirstLowerRest, 'Dart');
      expect('DART'.lowercaseFirstLetter, 'dART');
    });

    test('toTitle respects word exceptions', () {
      expect('the lord of the rings'.toTitle, 'the Lord of the Rings');
    });
  });
}
