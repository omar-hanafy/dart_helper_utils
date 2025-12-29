import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Intl map extensions', () {
    test('intlSelect picks value', () {
      final values = {'male': 'He', 'female': 'She', 'other': 'They'};
      expect(values.intlSelect('female'), 'She');
      expect(values.intlSelect('unknown'), 'They');
    });
  });

  group('Intl numeric extensions', () {
    test('pluralize uses correct branch', () {
      expect(1.pluralize(one: 'one', other: 'other'), 'one');
      expect(2.pluralize(one: 'one', other: 'other'), 'other');
    });

    test('getPluralCategory returns mapped value', () {
      final result = 1.getPluralCategory(one: 'one', other: 'other');
      expect(result, 'one');
    });
  });

  group('Intl string extensions', () {
    test('translate returns message', () {
      expect('Hello'.translate(), 'Hello');
    });

    test('genderSelect and getGenderCategory', () {
      expect(
        'male'.genderSelect(male: 'he', female: 'she', other: 'they'),
        'he',
      );
      final category = 'female'.getGenderCategory(
        female: 'she',
        male: 'he',
        other: 'they',
      );
      expect(category, 'she');
    });
  });
}
