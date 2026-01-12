// ignore_for_file: avoid_print
import 'package:collection/collection.dart';
import 'package:dart_helper_utils/dart_helper_utils.dart';

Future<void> main() async {
  print(20.formatAsReadableNumber(trimTrailingZeros: true));
  const rawJsonList = '[1.5, 2.3, 3.4]';
  final intList = tryConvertToList<int>(rawJsonList, defaultValue: []);
  print(intList); // [1, 2, 3]

  final list = <dynamic>[1, 2, '3', '3.1', 22.3];

  print(convertToList<num>(list)); // [1, 2, 3, 3.1, 22.3]
  print(convertToList<int>(list)); // [1, 2, 3, 3, 22]
  print(convertToList<double>(list)); // [1.0, 2.0, 3.0, 3.1, 22.3]
  print(convertToList<String>(list)); // ['1', '2', '3', '3.1', '22.3']

  // parsing raw Json to Map<String, dynamic>
  // note: you can also use Convert.toMap to avoid ambiguity.
  final userMap = convertToMap<String, dynamic>('''
{
    "name": "John",
    "age": 30,
    "wallet": 12.3,
    "codes": [1, 2, 3],
    "email": "john@example.com",
    "birthday": "12/12/1997"
}
''');

  // Example of using list converter & extensions.
  final codes = userMap.getList<int>('codes');
  print('First Code: ${codes.firstOrNull}');
  print('Random Code: ${codes.getRandom()}');

  // Example of using safe int conversions for dynamic data.
  final walletBalance = convertToInt(userMap['wallet']);
  // OR
  // final walletBalance = userMap.getInt('wallet');
  // final walletBalance = Convert.toInt(userMap['wallet']);
  print('user walletBalance: $walletBalance');

  // Example of using string extensions
  final userMail = convertToString(userMap['email']);
  print('Is Valid Email: ${userMail.isValidEmail}');

  // Example of using the global [httpStatusMessages]
  const httpStatusCode = 200;
  print('Status: $httpStatusCode - ${httpStatusMessages[httpStatusCode]}');
  print('Is Success: ${httpStatusCode.isSuccessCode}');
  print('Is Client Error: ${httpStatusCode.isClientErrorCode}');

  // quickly use normal date parsing via convert_object
  print('1997-08-12 00:00:00.000'.convert.toDateTime());

  // parsing complex datetime formats.
  const dateStr1 = '2024-06-09T15:30:00Z';
  const dateStr2 = 'June 9, 2024 3:30 PM';
  const dateStr3 = 'Tuesday, June 11th, 2024 at 2:15 PM';

  print(dateStr1.convert.toDateTime());
  print(dateStr2.convert.toDateTime());
  print(dateStr3.convert.toDateTime());

  const stringToConvert =
      '123Lorem-Ipsum_is_simply 12DummyText & of THE_PRINTING AND type_setting-industry.';

  // Convert to camelCase
  print('Convert to Camel Case:');
  print(stringToConvert.toCamelCase);

  // Convert to pascalCase
  print('Convert to Pascal Case:');
  print(stringToConvert.toPascalCase);

  // Convert to snake_case
  print('Convert to Snake Case:');
  print(stringToConvert.toSnakeCase);

  // Convert to camel_Snake_Case
  print('Convert to Camel Snake Case:');
  print(stringToConvert.toCamelSnakeCase);

  // Convert to kebab-case
  print('Convert to Kebab Case:');
  print(stringToConvert.toKebabCase);

  // Convert to Title Case
  print('Convert to Title Case:');
  print(stringToConvert.toTitleCase);

  // Unlike the toTitleCase, this one generates a title from string
  // while ignoring dashes and underscores. Useful for entity name formating.
  print('Generating a title while ignoring - and _');
  print(stringToConvert.toTitle);

  // [Flutter, And, Dart, are, AWESOME]
  print('FlutterAndDart_are-AWESOME'.toWords);

  // Converting a map with potentially complex data types to
  // a formatted JSON string using the safelyEncodedJson getter.
  final exampleMap = {
    'id': 2,
    'firstName': 'John',
    'lastName': 'Doe',
    'timePeriod': TimePeriod.week, // Example enum.
    'date': DateTime.now(),
    'isActive': true,
    'scores': [95, 85, 90], // List of integers
    'tags': {'flutter', 'dart'}, // Set of strings
    'nestedMap': {
      'key1': 'value1',
      'key2': 123,
      'key3': DateTime.now() - 1.asDays,
    },
  };

  // Convert the map to a formatted JSON string
  print(exampleMap.encodeWithIndent);

  // Convert the Map into a single-level map.
  print('Flat JSON: ${exampleMap.flatMap()}');

  // Examples for num extensions
  const num myNumber = 1234.56789;
  const num largeNumber = 123456789012345.6789;

  print('Currency: ${myNumber.formatAsCurrency()}');
  print('Simple Currency: ${myNumber.formatAsSimpleCurrency(name: 'USD')}');
  print('Compact: ${myNumber.formatAsCompact()}');
  print('Compact Long: ${largeNumber.formatAsCompactLong()}');
  print('Compact Currency: ${myNumber.formatAsCompactCurrency(name: '¥')}');
  print('Decimal: ${myNumber.formatAsDecimal()}');
  print('Percentage: ${myNumber.formatAsPercentage()}');
  print('Decimal Percent: ${myNumber.formatAsDecimalPercent()}');
  print('Scientific: ${myNumber.formatAsScientific()}');
  print('Custom Pattern: ${myNumber.formatWithCustomPattern('#,##0.00 €')}');

  // Example of using TimeUtils to measure execution duration of
  // a specific task. Works with both sync and async.
  final executionDuration = await TimeUtils.executionDuration(() {
    // measuring execution duration of generating 1 million list item 100 times;
    for (var i = 0; i < 100; i++) {
      List.generate(1000000, (index) => userMap);
    }
  });
  print(
    '1 Million list generated in: ${executionDuration.inMilliseconds} milliseconds',
  );

  // Example of comparing two tasks execution time using the TimeUtils class.
  final durations = await TimeUtils.compareExecutionTimes(
    taskA: () {
      for (var i = 0; i < 100; i++) {
        List.generate(1000000, (index) => userMap);
      }
    },
    taskB: () async => 100.millisecondsDelay(),
  );

  print(
    'TaskA took ${durations.$1.inMilliseconds} ms, TaskB took ${durations.$2.inMilliseconds} ms',
  );

  final result = await TimeUtils.runWithTimeout(
    task: () async {
      await 500.millisecondsDelay();
      return 'Completed';
    },
    timeout: const Duration(seconds: 1),
  );
  print('Result: $result');

  final httpDateTypeTestCases = {
    'Thu, 30 Aug 2024 12:00:00 GMT': 'RFC-1123',
    'Thursday, 30-Aug-24 12:00:00 GMT': 'RFC-850',
    'Thu Aug 30 12:00:00 2024': 'ANSI C asctime()',
    'Invalid date string': 'Invalid',
    'Wed, 31 Feb 2024 12:00:00 GMT': 'Invalid date',
    'Sun, 29 Feb 2024 12:00:00 GMT': 'RFC-1123 (Leap year)',
  };

  for (final entry in httpDateTypeTestCases.entries) {
    final dateStr = entry.key;
    final formatDescription = entry.value;
    final parsedDate = dateStr.convert.tryToDateTime();

    if (parsedDate != null) {
      print('Date string: "$dateStr" ($formatDescription)');
      print('Parsed DateTime: ${parsedDate.toIso8601String()}');
    } else {
      print('Date string: "$dateStr" ($formatDescription)');
      print('Parsing failed (DateTime is null)');
    }
    print('---');
  }
  print(12.toDecimalString(2)); // Output: 12
  print(12.10.toDecimalString(2)); // Output: 12.1
  print(12.1.toDecimalString(2, keepTrailingZeros: true)); // 12.10
  print(12.123.toDecimalString(2)); // 12.12

  final age = DateTime(1997, 8, 12).calculateAge();
  print('I am ${age.years} years old!');
}

// Example enum used in the map
enum TimePeriod { day, week, month }
