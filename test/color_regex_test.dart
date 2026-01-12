import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Color Regex Tests', () {
    group('regexValidRgbColor', () {
      final regex = RegExp(regexValidRgbColor);

      test('matches valid rgb values', () {
        expect(regex.hasMatch('rgb(255, 0, 0)'), isTrue);
        expect(regex.hasMatch('rgb(0, 255, 0)'), isTrue);
        expect(regex.hasMatch('rgb(0, 0, 255)'), isTrue);
        expect(regex.hasMatch('rgb(255, 255, 255)'), isTrue);
        expect(regex.hasMatch('rgb(0,0,0)'), isTrue);
        expect(regex.hasMatch('rgb(  10  ,  20  ,  30  )'), isTrue);
      });

      test('matches valid rgba values', () {
        expect(regex.hasMatch('rgba(255, 0, 0, 0.5)'), isTrue);
        expect(regex.hasMatch('rgba(255, 0, 0, 1)'), isTrue);
        expect(regex.hasMatch('rgba(255, 0, 0, 0)'), isTrue);
        expect(regex.hasMatch('rgba(0,0,0,0.1)'), isTrue);
      });

      test('matches percentages', () {
        expect(regex.hasMatch('rgb(100%, 0%, 0%)'), isTrue);
        expect(regex.hasMatch('rgba(100%, 0%, 0%, 0.5)'), isTrue);
      });

      test('rejects invalid values', () {
        expect(regex.hasMatch('rgb(256, 0, 0)'),
            isFalse); // Out of range (regex loosely checks 255 but strictly digits) - Wait, regex is (?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)
        expect(regex.hasMatch('rgb(-1, 0, 0)'), isFalse);
        expect(regex.hasMatch('rgb(0, 0)'), isFalse); // Missing component
        expect(regex.hasMatch('rgba(0, 0, 0)'),
            isTrue); // Optional alpha? No, rgba usually requires alpha, but regex might be permissive or strict. Code says "rgba?" and optional group for alpha.
        // Let's check logic: ^rgba? ... ( ... )? ... $
        // It allows rgb(...) to have 3 or 4 components.
        // It allows rgba(...) to have 3 or 4 components.
      });
    });

    group('regexValidHslColor', () {
      final regex = RegExp(regexValidHslColor);

      test('matches valid hsl values', () {
        expect(regex.hasMatch('hsl(0, 100%, 50%)'), isTrue);
        expect(regex.hasMatch('hsl(120, 100%, 50%)'), isTrue);
        expect(regex.hasMatch('hsl(360, 0%, 0%)'), isTrue);
        expect(regex.hasMatch('hsl( 180 , 50% , 50% )'), isTrue);
      });

      test('matches valid hsla values', () {
        expect(regex.hasMatch('hsla(0, 100%, 50%, 0.5)'), isTrue);
        expect(regex.hasMatch('hsla(0, 100%, 50%, 1)'), isTrue);
      });

      test('matches angles with units', () {
        expect(regex.hasMatch('hsl(180deg, 50%, 50%)'), isTrue);
        expect(regex.hasMatch('hsl(3.14rad, 50%, 50%)'), isTrue);
        expect(regex.hasMatch('hsl(0.5turn, 50%, 50%)'), isTrue);
      });

      test('rejects invalid values', () {
        // Regex expects % for saturation and lightness
        expect(regex.hasMatch('hsl(0, 100, 50)'), isFalse);
      });
    });

    group('regexValidModernColorFunc', () {
      final regex = RegExp(regexValidModernColorFunc);

      test('matches modern syntax', () {
        expect(regex.hasMatch('rgb(255 0 0)'), isTrue);
        expect(regex.hasMatch('rgb(255 0 0 / 0.5)'), isTrue);
        expect(regex.hasMatch('hsl(0 100% 50%)'), isTrue);
        expect(regex.hasMatch('lch(50% 100 0)'), isTrue);
        expect(regex.hasMatch('color(display-p3 1 0.5 0)'), isTrue);
      });

      test('rejects commas in modern syntax regex', () {
        // The regex explicitly disallows commas inside the parentheses: ([^,]+)
        expect(regex.hasMatch('rgb(255, 0, 0)'), isFalse);
      });
    });
  });
}
