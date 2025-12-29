import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('String Extensions', () {
    test('truncate shortens string', () {
      expect('Hello World'.truncate(5), 'Hello...');
      expect('Hello'.truncate(10), 'Hello');
    });

    test('truncate custom suffix', () {
      expect('Hello World'.truncate(5, suffix: '!'), 'Hello!');
    });

    test('maskEmail hides characters', () {
      expect('johndoe@example.com'.maskEmail, 'jo****@example.com');
      expect('ab@c.com'.maskEmail, 'a****@c.com'); // fallback for short
    });

    test('mask hides characters', () {
      expect('1234567890'.mask(visibleStart: 2, visibleEnd: 2), '12******90');
      expect(
        '123'.mask(visibleStart: 2, visibleEnd: 2),
        '123',
      ); // too short to mask
    });

    test('isUuid validates UUID', () {
      expect('123e4567-e89b-12d3-a456-426614174000'.isUuid, isTrue);
      expect('invalid-uuid'.isUuid, isFalse);
    });
  });
}
