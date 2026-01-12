import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Ordinal Tests', () {
    // Single-Digit Numbers
    test('Single-digit numbers', () {
      expectOrdinal(0, 'zeroth', '0th');
      expectOrdinal(1, 'first', '1st');
      expectOrdinal(2, 'second', '2nd');
      expectOrdinal(3, 'third', '3rd');
      expectOrdinal(4, 'fourth', '4th');
      expectOrdinal(5, 'fifth', '5th');
      expectOrdinal(6, 'sixth', '6th');
      expectOrdinal(7, 'seventh', '7th');
      expectOrdinal(8, 'eighth', '8th');
      expectOrdinal(9, 'ninth', '9th');
    });

    // Teens
    test('Teens', () {
      expectOrdinal(10, 'tenth', '10th');
      expectOrdinal(11, 'eleventh', '11th');
      expectOrdinal(12, 'twelfth', '12th');
      expectOrdinal(13, 'thirteenth', '13th');
      expectOrdinal(14, 'fourteenth', '14th');
      expectOrdinal(15, 'fifteenth', '15th');
      expectOrdinal(16, 'sixteenth', '16th');
      expectOrdinal(17, 'seventeenth', '17th');
      expectOrdinal(18, 'eighteenth', '18th');
      expectOrdinal(19, 'nineteenth', '19th');
    });

    // Tens
    test('Tens', () {
      expectOrdinal(20, 'twentieth', '20th');
      expectOrdinal(30, 'thirtieth', '30th');
      expectOrdinal(40, 'fortieth', '40th');
      expectOrdinal(50, 'fiftieth', '50th');
      expectOrdinal(60, 'sixtieth', '60th');
      expectOrdinal(70, 'seventieth', '70th');
      expectOrdinal(80, 'eightieth', '80th');
      expectOrdinal(90, 'ninetieth', '90th');
    });

    // Compound Numbers (21-99)
    test('Compound Numbers', () {
      expectOrdinal(21, 'twenty-first', '21st');
      expectOrdinal(32, 'thirty-second', '32nd');
      expectOrdinal(43, 'forty-third', '43rd');
      expectOrdinal(54, 'fifty-fourth', '54th');
      expectOrdinal(65, 'sixty-fifth', '65th');
      expectOrdinal(76, 'seventy-sixth', '76th');
      expectOrdinal(87, 'eighty-seventh', '87th');
      expectOrdinal(98, 'ninety-eighth', '98th');
      expectOrdinal(99, 'ninety-ninth', '99th');
    });

    // Edge Cases Around 100
    test('Edge Cases Around 100', () {
      expectOrdinal(100, 'one hundredth', '100th');
      expectOrdinal(101, 'one hundred first', '101st');
      expectOrdinal(110, 'one hundred tenth', '110th');
      expectOrdinal(111, 'one hundred eleventh', '111th');
      expectOrdinal(120, 'one hundred twentieth', '120th');
      expectOrdinal(121, 'one hundred twenty-first', '121st');
    });

    // Negative Numbers (should throw an ArgumentError)
    test('Negative numbers throw an ArgumentError', () {
      expect(() => expectOrdinal(-1, '', ''), throwsA(isA<ArgumentError>()));
      expect(() => expectOrdinal(-100, '', ''), throwsA(isA<ArgumentError>()));
    });

    // Non-Integer Numbers (should be converted to integers)
    test('Non-Integer Numbers', () {
      expectOrdinal(1.0, 'first', '1st');
      expectOrdinal(1.5, 'first', '1st');
      expectOrdinal(2.9, 'second', '2nd');
    });

    // Very Large Number with 'and'
    test('Very Large Number with "and"', () {
      expectOrdinal(
        1234567890,
        'one billion two hundred thirty-four million five hundred sixty-seven thousand eight hundred and ninetieth',
        '1234567890th',
        includeAnd: true,
      );
    });
  });
}

void expectOrdinal(
  num number,
  String expectedWord,
  String expectedSuffix, {
  bool includeAnd = false,
}) {
  final actualWord = number.toOrdinal(asWord: true, includeAnd: includeAnd);
  final actualSuffix = number.toOrdinal();

  expect(actualWord, expectedWord, reason: 'Expected ordinal word for $number');
  expect(
    actualSuffix,
    expectedSuffix,
    reason: 'Expected ordinal suffix for $number',
  );
}
