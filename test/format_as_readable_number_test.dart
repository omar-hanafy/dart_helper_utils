import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Readable Number Formatting Tests', () {
    const number = 1000000.50;

    void runTest({
      required String testName,
      required num input,
      required String expectedOutput,
      String? locale,
      int decimalDigits = 2,
      String? groupingSeparator,
      String? decimalSeparator,
      bool trimTrailingZeros = false,
    }) {
      test(testName, () {
        final result = input.formatAsReadableNumber(
          locale: locale,
          decimalDigits: decimalDigits,
          groupingSeparator: groupingSeparator,
          decimalSeparator: decimalSeparator,
          trimTrailingZeros: trimTrailingZeros,
        );
        expect(result, expectedOutput);
      });
    }

    runTest(
      testName: 'Default formatting',
      input: number,
      expectedOutput: '1,000,000.50',
    );

    runTest(
      testName: 'Trimming trailing zeros',
      input: number,
      trimTrailingZeros: true,
      expectedOutput: '1,000,000.5',
    );

    runTest(
      testName: 'No decimal digits',
      input: number,
      decimalDigits: 0,
      expectedOutput: '1,000,001',
    );

    runTest(
      testName: 'Custom grouping and decimal separators',
      input: number,
      groupingSeparator: '.',
      decimalSeparator: ',',
      expectedOutput: '1.000.000,50',
    );

    runTest(
      testName: 'European formatting with locale',
      input: number,
      locale: 'de_DE',
      expectedOutput: '1.000.000,50',
    );

    runTest(
      testName: 'Indian numbering system',
      input: number,
      locale: 'en_IN',
      expectedOutput: '10,00,000.50',
    );

    runTest(
      testName: 'Indian numbering with custom separators',
      input: number,
      locale: 'en_IN',
      groupingSeparator: ',',
      decimalDigits: 0,
      trimTrailingZeros: true,
      expectedOutput: '10,00,001',
    );

    runTest(
      testName: 'Custom decimal digits',
      input: number,
      decimalDigits: 3,
      expectedOutput: '1,000,000.500',
    );

    runTest(
      testName: 'Custom separators and locale',
      input: number,
      locale: 'fr_FR',
      groupingSeparator: ' ',
      decimalSeparator: ',',
      expectedOutput: '1 000 000,50',
    );

    runTest(
      testName: 'Large number with custom separators',
      input: 1234567890,
      groupingSeparator: ' ',
      decimalDigits: 0,
      expectedOutput: '1 234 567 890',
    );
  });
}
