import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

class _CustomType {
  const _CustomType();
}

void main() {
  group('Global functions', () {
    test('isValuePrimitive detects primitives and collections', () {
      expect(isValuePrimitive(10), isTrue);
      expect(isValuePrimitive('text'), isTrue);
      expect(isValuePrimitive(DateTime(2024, 1, 1)), isTrue);
      expect(isValuePrimitive([1, 2, 3]), isTrue);
      expect(isValuePrimitive({'a': 1, 'b': true}), isTrue);
      expect(isValuePrimitive({'a': const _CustomType()}), isFalse);
      expect(isValuePrimitive([const _CustomType()]), isFalse);
    });

    test('isTypePrimitive recognizes primitive types', () {
      expect(isTypePrimitive<int>(), isTrue);
      expect(isTypePrimitive<double>(), isTrue);
      expect(isTypePrimitive<String>(), isTrue);
      expect(isTypePrimitive<DateTime>(), isTrue);
      expect(isTypePrimitive<_CustomType>(), isFalse);
    });

    test('isEqual performs deep equality', () {
      expect(isEqual([1, 2, 3], [1, 2, 3]), isTrue);
      expect(isEqual([1, 2, 3], [3, 2, 1]), isFalse);
      expect(
        isEqual(
          {
            'a': [1, 2],
          },
          {
            'a': [1, 2],
          },
        ),
        isTrue,
      );
    });

    test('time helpers are close to now', () {
      final start = DateTime.now();
      final nowValue = now;
      final epochValue = currentMillisecondsSinceEpoch;
      expect(nowValue.difference(start).inSeconds.abs(), lessThan(2));
      expect(
        (DateTime.now().millisecondsSinceEpoch - epochValue).abs(),
        lessThan(2000),
      );
    });

    test('random helpers are deterministic with seed', () {
      expect(randomBool(42), randomBool(42));
      expect(randomInt(10, 42), randomInt(10, 42));
      expect(randomDouble(42), randomDouble(42));
      expect(randomInt(10, 1), lessThan(10));
      expect(randomDouble(1), inInclusiveRange(0, 1));
    });
  });
}
