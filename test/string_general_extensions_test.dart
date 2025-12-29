import 'dart:convert';

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('String general extensions', () {
    test('nullIfEmpty and nullIfBlank', () {
      expect(''.nullIfEmpty, isNull);
      expect('text'.nullIfEmpty, 'text');
      expect('   '.nullIfBlank, isNull);
      expect('text'.nullIfBlank, 'text');
    });

    test('removeEmptyLines and toOneLine', () {
      expect('Line1\n\n\nLine2'.removeEmptyLines, 'Line1\nLine2');
      expect('Line1\nLine2'.toOneLine, 'Line1Line2');
    });

    test('removeWhiteSpaces and clean', () {
      expect('a b c'.removeWhiteSpaces, 'abc');
      expect('a b\nc'.clean, 'abc');
    });

    test('words and lines', () {
      expect('Hello World'.words, ['Hello', 'World']);
      expect('  Hello   World  '.words, ['Hello', 'World']);
      expect('Hello\nWorld'.words, ['Hello', 'World']);
      expect(''.words, []);

      expect('Line 1\nLine 2'.lines, ['Line 1', 'Line 2']);
      expect('Line 1\r\nLine 2'.lines, ['Line 1', 'Line 2']);
      expect(''.lines, ['']);
    });

    test('base64Encode/base64Decode round-trip', () {
      final original = 'hello';
      final encoded = original.base64Encode();
      expect(base64.decode(encoded), isNotEmpty);
      expect(encoded.base64Decode(), original);
    });

    test('toCharArray and insert', () {
      expect('abc'.toCharArray(), ['a', 'b', 'c']);
      expect('abc'.insert(1, 'Z'), 'aZbc');
    });

    test('isPalindrome', () {
      expect('A man a plan a canal Panama'.isPalindrome, isTrue);
      expect('hello'.isPalindrome, isFalse);
    });

    test('validation helpers', () {
      expect('test@email.com'.isValidEmail, isTrue);
      expect('+1234567890'.isValidPhoneNumber, isTrue);
      expect('https://example.com'.isValidUrl, isTrue);
      expect('192.168.1.1'.isValidIp4, isTrue);
      expect('12345'.isNumeric, isTrue);
      expect(' 12345 '.isNumeric, isTrue, reason: 'Should trim whitespace');
      expect('12.34'.isNumeric, isFalse, reason: 'ASCII digits only');
      expect('abcDEF'.isAlphabet, isTrue);
      expect(' abcDEF '.isAlphabet, isTrue, reason: 'Should trim whitespace');
      expect('abc1'.isAlphabet, isFalse);
      expect('Hello'.hasCapitalLetter, isTrue);
      expect('true'.isBool, isTrue);
      expect(' FALSE '.isBool, isTrue);
    });

    test('equalsIgnoreCase', () {
      expect('Hello'.equalsIgnoreCase('hello'), isTrue);
      expect('Hello'.equalsIgnoreCase('world'), isFalse);
    });

    test('removeSurrounding', () {
      expect('"value"'.removeSurrounding('"'), 'value');
      expect('value'.removeSurrounding('"'), 'value');
    });

    test('replaceAfter and replaceBefore', () {
      expect('foo=bar'.replaceAfter('=', 'baz'), 'foo=baz');
      expect('foo=bar'.replaceBefore('=', 'baz'), 'baz=bar');
      expect('foo'.replaceAfter(':', 'x', 'fallback'), 'fallback');
      expect('foo'.replaceBefore(':', 'x', 'fallback'), 'fallback');
    });

    test('anyChar and orEmpty', () {
      expect('abc'.anyChar((c) => c == 'b'), isTrue);
      String? value;
      expect(value.orEmpty, '');
    });

    test('ifEmpty and lastIndex', () async {
      final result = await ''.ifEmpty(() async => 'fallback');
      expect(result, 'fallback');
      expect('abc'.lastIndex, 'c');
    });

    test('limitFromEnd and limitFromStart', () {
      expect('abcdef'.limitFromEnd(3), 'def');
      expect('abcdef'.limitFromStart(3), 'abc');
    });
  });
}
