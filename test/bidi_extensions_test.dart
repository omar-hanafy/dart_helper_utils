import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Bidi string extensions', () {
    test('LTR detection helpers', () {
      const text = 'Hello world';
      expect(text.startsWithLtr(), isTrue);
      expect(text.endsWithLtr(), isTrue);
      expect(text.hasAnyLtr(), isTrue);
      expect(text.hasAnyRtl(), isFalse);
    });

    test('isRtlLanguage uses language codes', () {
      expect('ar'.isRtlLanguage(), isTrue);
      expect('en'.isRtlLanguage(), isFalse);
    });
  });
}
