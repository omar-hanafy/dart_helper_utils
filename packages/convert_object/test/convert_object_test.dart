import 'package:convert_object/convert_object.dart';
import 'package:convert_object/src/extensions/map_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('Primitive Conversions', () {
    test('toText conversions', () {
      expect(123.convert.toText(), '123');
      expect(true.convert.toText(), 'true');
      expect(3.14.convert.toText(), '3.14');
      expect([1, 2, 3].convert.toText(), '[1, 2, 3]');
    });

    test('toInt conversions', () {
      expect('123'.convert.toInt(), 123);
      expect(123.45.convert.toInt(), 123);
      expect('  456  '.convert.toInt(), 456);
      expect(() => true.convert.toInt(), throwsA(isA<ConversionException>()));
    });

    test('toDouble conversions', () {
      expect('3.14'.convert.toDouble(), 3.14);
      expect(42.convert.toDouble(), 42.0);
      expect('  2.71  '.convert.toDouble(), 2.71);
    });

    test('toBool conversions', () {
      expect(true.convert.toBool(), true);
      expect('true'.convert.toBool(), true);
      expect('yes'.convert.toBool(), true);
      expect('1'.convert.toBool(), true);
      expect(1.convert.toBool(), true);
      expect(42.convert.toBool(), true);

      expect(false.convert.toBool(), false);
      expect('false'.convert.toBool(), false);
      expect('no'.convert.toBool(), false);
      expect('0'.convert.toBool(), false);
      expect(0.convert.toBool(), false);
      expect((-1).convert.toBool(), false);
      expect(null.convert.toBool(), false);
    });

    test('safe conversions with OrNull', () {
      expect(null.convert.tryToText(), null);
      expect('abc'.convert.tryToInt(), null);
      expect('123'.convert.tryToInt(), 123);
    });

    test('conversions with default values', () {
      expect(null.convert.toTextOr('default'), 'default');
      expect('abc'.convert.toIntOr(42), 42);
      expect('123'.convert.toIntOr(42), 123);
    });
  });

  group('BigInt Conversions', () {
    test('toBigInt conversions', () {
      expect('123456789012345678901234567890'.convert.toBigInt(),
          BigInt.parse('123456789012345678901234567890'));
      expect(42.convert.toBigInt(), BigInt.from(42));
      expect(3.14.convert.toBigInt(), BigInt.from(3));
    });
  });

  group('DateTime Conversions', () {
    test('toDateTime conversions', () {
      const isoDate = '2024-01-15T10:30:00.000Z';
      final parsed = isoDate.convert.toDateTime();
      expect(parsed.year, 2024);
      expect(parsed.month, 1);
      expect(parsed.day, 15);

      final fromMillis = 1705316400000.convert.toDateTime();
      expect(fromMillis.year, 2024);
    });
  });

  group('Uri Conversions', () {
    test('toUri conversions', () {
      expect('https://example.com'.convert.toUri().toString(),
          'https://example.com');
      expect('+1234567890'.convert.toUri().toString(), 'tel:+1234567890');
      expect('user@example.com'.convert.toUri().toString(),
          'mailto:user@example.com');
    });
  });

  group('Collection Conversions', () {
    test('toList conversions', () {
      expect([1, 2, 3].convert.toList<int>(), [1, 2, 3]);
      expect('single'.convert.toList<String>(), ['single']);
      expect({'a': 1, 'b': 2}.convert.toList<int>(), [1, 2]);
      expect({1, 2, 3}.convert.toList<int>(), [1, 2, 3]);
    });

    test('toSet conversions', () {
      expect([1, 2, 2, 3].convert.toSet<int>(), {1, 2, 3});
      expect('single'.convert.toSet<String>(), {'single'});
    });

    test('toMap conversions', () {
      expect(
          {'a': '1', 'b': '2'}.convert.toMap<String, int>(
              valueConverter: (v) => int.parse(v.toString())),
          {'a': 1, 'b': 2});
    });
  });

  group('Iterable Extensions', () {
    test('getAs methods', () {
      final list = ['123', '456', 'true', '3.14'];

      expect(list.getInt(0), 123);
      expect(list.getInt(1), 456);
      expect(list.getBool(2), true);
      expect(list.getDouble(3), 3.14);
    });

    test('convertAll', () {
      expect(['1', '2', '3'].convertAll<int>(), [1, 2, 3]);
      expect([1, 2, 3].convertAll<String>(), ['1', '2', '3']);
    });
  });

  group('Map Extensions', () {
    test('getAs methods', () {
      final map = {
        'name': 'John',
        'age': '30',
        'active': 'true',
        'score': '98.5',
      };

      expect(map.getSet<dynamic>('name'), 'John');
      expect(map.getInt('age'), 30);
      expect(map.getBool('active'), true);
      expect(map.getDouble('score'), 98.5);
    });

    test('alternative keys', () {
      final map = {'username': 'john_doe'};

      expect(map.getString('user_id', alternativeKeys: ['userId', 'username']),
          'john_doe');
    });

    test('nested access', () {
      final map = {
        'user': {
          'profile': {'age': '25'}
        }
      };

      final age = map.convert
          .fromMap('user')
          .fromMap('profile')
          .toMap<String, dynamic>()
          .getInt('age');

      expect(age, 25);
    });
  });

  group('Converter Fluent API', () {
    test('chaining operations', () {
      final data = {
        'values': ['1', '2', '3']
      };

      final sum = data.convert
          .fromMap('values')
          .toList<String>()
          .convertAll<int>()
          .fold(0, (sum, value) => sum + value);

      expect(sum, 6);
    });

    test('with options', () {
      const value = '42';

      final result = value.convert
          .withDefault(0)
          .withConverter((v) => int.parse(v.toString()) * 2)
          .to<int>();

      expect(result, 84);
    });
  });

  group('Let Extensions', () {
    test('let on non-null', () {
      final result = 'hello'.let((s) => s.toUpperCase());
      expect(result, 'HELLO');
    });

    test('let on null', () {
      const String? nullString = null;
      final result = nullString.let((s) => s.toUpperCase());
      expect(result, null);
    });

    test('letOr', () {
      const String? nullString = null;
      final result = nullString.letOr(
        (s) => s.toUpperCase(),
        defaultValue: 'DEFAULT',
      );
      expect(result, 'DEFAULT');

      final nonNull = 'hello'.letOr(
        (s) => s.toUpperCase(),
        defaultValue: 'DEFAULT',
      );
      expect(nonNull, 'HELLO');
    });
  });
}
