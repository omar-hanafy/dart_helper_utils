import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  print(tryToList<int>('[1.5, 2.3, 3.4]'));

  // {hello, world}
  print(toSet<String>('["hello", "world"]'));

  const rawJson = '''
{
    "name": "John",
    "age": "30",
    "wallet": "12.3",
    "codes": "[1, 2, 3]",
    "email": "john@example.com"
}
''';

  // Example of using dynamic conversions and decode on string.
  final user = toMap<String, dynamic>(rawJson);

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

  // Example of using map extensions
  print('Flat JSON: ${user.flatJson()}');

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
  final jsonString = exampleMap.safelyEncodedJson;

  // Print the JSON string
  print(jsonString);

  const value = 12345.6789;

  print(value.formatAsCurrency()); // Output: $12,345.68
  print(value.formatAsSimpleCurrency()); // Output: $12,345.68
  print(value.formatAsCompact()); // Output: 12K
  print(value.formatAsCompactLong()); // Output: 12 thousand
  print(value.formatAsCompactCurrency()); // Output: $12K
  print(value.formatAsDecimal()); // Output: 12,345.68
  print(value.formatAsPercentage()); // Output: 1,234,568%
  print(value.formatWithCustomPattern('#,##0.00')); // Output: 12,345.68

  // Add tryParse to NumberFormat
  final numberFormat = NumberFormat.currency(locale: 'en_US', symbol: r'$');
  final parsedNumber = numberFormat.tryParse(r'1,234.56');
  print('${numberFormat.symbols} Parsed number: $parsedNumber');

  // Add tryParse, tryParseStrict, tryParseLoose, tryParseUtc to DateFormat
  final dateFormat = DateFormat('yyyy-MM-dd');
  final parsedDate = dateFormat.tryParse('2024-06-03');
  final parsedDateStrict = dateFormat.tryParseStrict('2024-06-03');
  final parsedDateLoose = dateFormat.tryParseLoose('June 3, 2024');
  final parsedDateUtc = dateFormat.tryParseUtc('2024-06-03T00:00:00Z');
  print('Parsed date (tryParse): $parsedDate');
  print('Parsed date (tryParseStrict): $parsedDateStrict');
  print('Parsed date (tryParseLoose): $parsedDateLoose');
  print('Parsed date (tryParseUtc): $parsedDateUtc');

  // Add fallback for deprecated locales, such as he <-> iw
  final deprecatedLocaleFormat = DateFormat.yMMMMd('en_US');
  print(
      'Deprecated locale fallback example: ${deprecatedLocaleFormat.format(DateTime.now())}');

  // Switch QAR currency name to Riyal
  final qarFormat = NumberFormat.simpleCurrency(name: 'QAR');
  print('QAR currency name: ${qarFormat.currencyName}');

  // Update CVE currency symbol
  final cveFormat = NumberFormat.simpleCurrency(name: 'CVE');
  print('CVE currency symbol: ${cveFormat.currencySymbol}');

  // Add EEEEE skeleton for DateFormat
  final eeeeeFormat = DateFormat('EEEEE', 'en_US');
  print('EEEEE skeleton example: ${eeeeeFormat.format(DateTime.now())}');

  // Fix issue #483 about date parsing with a yy skeleton
  final yyFormat = DateFormat('yy');
  final parsedYYDate = yyFormat.parse('24');
  print('Parsed date (yy): ${parsedYYDate.year}');

  // Update to CLDR v42 (usage remains the same, but benefits from latest data)
  final cldr42Format = DateFormat.yMMMMd('en_US');
  print('CLDR v42 example: ${cldr42Format.format(DateTime.now())}');

  // Update ruble sign and update corresponding test
  final rubFormat = NumberFormat.simpleCurrency(name: 'RUB');
  print('Ruble currency symbol: ${rubFormat.currencySymbol}');
}

// Example enum used in the map
enum TimePeriod {
  day,
  week,
  month,
}
