import 'package:dart_helper_utils/dart_helper_utils.dart';

Future<void> main() async {
  // parsing raw array of doubles to List<int>.
  print(tryToList<int>('[1.5, 2.3, 3.4]'));

  // quickly use normal date parsing.
  print('1997-08-12 00:00:00.000'.toDateTime);

  // parsing complex datetime formats.
  print('12/08/1997'.toDateFormatted());

  // parsing raw array of Strings to Set<String>.
  print(toSet<String>('["hello", "world"]'));

  // parsing raw Json to Map<String, dynamic>
  final user = toMap<String, dynamic>('''
{
    "name": "John",
    "age": 30,
    "wallet": 12.3,
    "codes": [1, 2, 3],
    "email": "john@example.com",
    "birthday": "12/12/1997"
}
''');

  // Example of using safe int conversions for dynamic data.
  final walletBalance = toInt(user['wallet']);
  print('user walletBalance: $walletBalance');

  // Example of using list converter & extensions.
  final codes = tryToList<int>(user['codes']);
  print('First Code: ${codes.firstOrNull}');
  print('Random Code: ${codes?.getRandom()}');

  // Example of using string extensions
  final userMail = toString1(user['email']);
  print('Is Valid Email: ${userMail.isValidEmail}');

  // Example of using HttpResStatus
  final status = 200.toHttpResStatus;
  print('Status: ${status.code} - ${status.desc}');
  print('Is Success: ${status.isSuccess}');
  print('Is Client Error: ${status.isClientError}');

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

  print('FlutterAndDart_are-AWESOME'.toWords); // [FlutterAndDart, are-AWESOME]

  // Example of using TimeUtils to measure execution duration of
  // a specific task. Works with both sync and async.
  final executionDuration = await TimeUtils.executionDuration(() {
    // measuring execution duration of generating 1 million list item 100 times;
    for (var i = 0; i < 100; i++) {
      List.generate(1000000, (index) => user);
    }
  });
  print(
      '1 Million list generated in: ${executionDuration.inMilliseconds} milliseconds');

  // Example of comparing two tasks execution time using the TimeUtils class.
  final durations = await TimeUtils.compareExecutionTimes(
    taskA: () {
      for (var i = 0; i < 100; i++) {
        List.generate(1000000, (index) => user);
      }
    },
    taskB: () async => 100.millisecondsDelay,
  );

  print(
    'TaskA took ${durations.$1.inMilliseconds} ms, TaskB took ${durations.$2.inMilliseconds} ms',
  );

  final result = await TimeUtils.runWithTimeout(
    task: () async {
      await 500.millisecondsDelay;
      return 'Completed';
    },
    timeout: const Duration(seconds: 1),
  );
  print('Result: $result');

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
    }
  };

  // Convert the map to a formatted JSON string
  print(exampleMap.encodedJsonString);

  // Convert the Map into a single-level map.
  print('Flat JSON: ${exampleMap.flatMap()}');

  // Currency Formatting
  // Egypt Pound
  print('Currency format: ${'E£'.symbolCurrencyFormat().currencyName}');
  // European Euro
  print('Currency format: ${'€'.symbolCurrencyFormat().currencyName}');
  // Japanese Yen
  print('Currency format: ${'¥'.symbolCurrencyFormat().currencyName}');
  // United State Dollar
  print('Currency format: ${r'$'.symbolCurrencyFormat().currencyName}');

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
}

// Example enum used in the map
enum TimePeriod {
  day,
  week,
  month,
}
