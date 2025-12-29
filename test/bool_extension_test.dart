import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Bool extensions', () {
    test('toggled flips value', () {
      expect(true.toggled, isFalse);
      expect(false.toggled, isTrue);
    });

    test('nullable helpers', () {
      bool? value;
      expect(value.isTrue, isFalse);
      expect(value.isFalse, isFalse);
      expect(value.val, isFalse);
      expect(value.binary, 0);
      expect(value.binaryText, '0');
      expect(value.toggled, isNull);

      value = true;
      expect(value.isTrue, isTrue);
      expect(value.isFalse, isFalse);
      expect(value.val, isTrue);
      expect(value.binary, 1);
      expect(value.binaryText, '1');
      expect(value.toggled, isFalse);

      value = false;
      expect(value.isTrue, isFalse);
      expect(value.isFalse, isTrue);
      expect(value.val, isFalse);
      expect(value.binary, 0);
      expect(value.binaryText, '0');
      expect(value.toggled, isTrue);
    });
  });
}
