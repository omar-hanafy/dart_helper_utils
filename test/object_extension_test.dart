import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

class _CustomType {
  const _CustomType(this.value);

  final int value;
}

void main() {
  group('Object extensions', () {
    test('isPrimitive recognizes primitives and collections', () {
      const Object primitive = 1;
      expect(primitive.isPrimitive(), isTrue);
      expect(['a', 'b'].isPrimitive(), isTrue);
      expect({'a': 1, 'b': true}.isPrimitive(), isTrue);
      expect(const _CustomType(1).isPrimitive(), isFalse);
      expect([const _CustomType(1)].isPrimitive(), isFalse);
    });

    test('let returns transformed value', () {
      final result = DHUScopeFunctions(5).let((it) => it * 2);
      expect(result, 10);
    });

    test('also returns original value', () {
      var tapped = 0;
      final result = 5.also((it) => tapped = it);
      expect(result, 5);
      expect(tapped, 5);
    });

    test('takeIf and takeUnless', () {
      expect(5.takeIf((it) => it > 3), 5);
      expect(5.takeIf((it) => it < 3), isNull);
      expect(5.takeUnless((it) => it > 3), isNull);
      expect(5.takeUnless((it) => it < 3), 5);
    });
  });
}
