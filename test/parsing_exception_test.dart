import 'package:test/test.dart';
import 'package:dart_helper_utils/dart_helper_utils.dart';

void main() {
  group('ParsingException comprehensive debugging', () {
    test('should include all arguments in parsingInfo', () {
      try {
        ConvertObject.toInt(
          'invalid',
          mapKey: 'age',
          listIndex: 5,
          format: 'en_US',
          locale: 'US',
          // Don't provide defaultValue so it throws
        );
        fail('Should have thrown ParsingException');
      } catch (e) {
        expect(e, isA<ParsingException>());
        final exception = e as ParsingException;

        // Check that all arguments are present in parsingInfo
        expect(exception.parsingInfo['method'], equals('toInt'));
        expect(exception.parsingInfo['object'], equals('invalid'));
        expect(exception.parsingInfo['objectType'], equals('String'));
        expect(exception.parsingInfo['mapKey'], equals('age'));
        expect(exception.parsingInfo['listIndex'], equals(5));
        expect(exception.parsingInfo['format'], equals('en_US'));
        expect(exception.parsingInfo['locale'], equals('US'));
      }
    });

    test('should filter heavy objects from default toString', () {
      final largeMap = Map.fromIterables(
        List.generate(100, (i) => 'key$i'),
        List.generate(100, (i) => 'value$i'),
      );

      try {
        ConvertObject.toInt(largeMap);
        fail('Should have thrown ParsingException');
      } catch (e) {
        expect(e, isA<ParsingException>());
        final exception = e as ParsingException;

        // toString should show placeholder for large map
        final str = exception.toString();
        expect(str.contains('<Map with 100 entries>'), isTrue);
        expect(str.contains('key0'), isFalse); // Actual map content not shown

        // But parsingInfo should still contain the actual object
        expect(exception.parsingInfo['object'], equals(largeMap));
      }
    });

    test('should provide fullReport with complete information', () {
      final testList = List.generate(50, (i) => 'item$i');

      try {
        ConvertObject.toBool(testList);
      } catch (e) {
        expect(e, isA<ParsingException>());
        final exception = e as ParsingException;

        // Default toString filters large list
        final defaultStr = exception.toString();
        expect(defaultStr.contains('<List with 50 items>'), isTrue);

        // fullReport shows everything
        final fullReport = exception.fullReport();
        expect(fullReport.contains('"object"'), isTrue);
        expect(fullReport.contains('ParsingException (Full Report)'), isTrue);
      }
    });

    test('should handle toType with comprehensive info', () {
      try {
        toType<Uri>('not a valid uri');
        fail('Should have thrown ParsingException');
      } catch (e) {
        expect(e, isA<ParsingException>());
        final exception = e as ParsingException;

        expect(exception.parsingInfo['method'], equals('toType<Uri>'));
        expect(exception.parsingInfo['targetType'], equals('Uri'));
        expect(exception.parsingInfo['objectType'], equals('String'));
      }
    });

    test('should handle null objects with proper context', () {
      try {
        ConvertObject.toDateTime(
          null,
          format: 'yyyy-MM-dd',
          locale: 'en_US',
          autoDetectFormat: true,
          utc: true,
        );
        fail('Should have thrown ParsingException');
      } catch (e) {
        expect(e, isA<ParsingException>());
        final exception = e as ParsingException;

        expect(exception.error, equals('object is unsupported or null'));
        expect(exception.parsingInfo['method'], equals('toDateTime'));
        expect(exception.parsingInfo['format'], equals('yyyy-MM-dd'));
        expect(exception.parsingInfo['locale'], equals('en_US'));
        expect(exception.parsingInfo['autoDetectFormat'], equals(true));
        expect(exception.parsingInfo['utc'], equals(true));
      }
    });

    test('should not include null parameters in parsingInfo', () {
      try {
        ConvertObject.toNum('invalid');
        fail('Should have thrown ParsingException');
      } catch (e) {
        expect(e, isA<ParsingException>());
        final exception = e as ParsingException;

        // Only non-null parameters should be in parsingInfo
        expect(exception.parsingInfo.containsKey('method'), isTrue);
        expect(exception.parsingInfo.containsKey('object'), isTrue);
        expect(exception.parsingInfo.containsKey('objectType'), isTrue);

        // These were not provided, so should not be in parsingInfo
        expect(exception.parsingInfo.containsKey('mapKey'), isFalse);
        expect(exception.parsingInfo.containsKey('listIndex'), isFalse);
        expect(exception.parsingInfo.containsKey('format'), isFalse);
      }
    });
  });
}
