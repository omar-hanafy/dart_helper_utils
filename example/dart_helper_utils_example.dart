import 'package:dart_helper_utils/dart_helper_utils.dart';

Future<void> main() async {
  // parsing dynamic numeric list to num, int, and double.
  final list = <dynamic>[1, 2, '3', '3.1', 22.3];

  print(list.convertTo<num>()); // [1, 2, 3, 3.1, 22.3]
  print(list.convertTo<int>()); // [1, 2, 3, 3, 22]
  print(list.convertTo<double>()); // [1.0, 2.0, 3.0, 3.1, 22.3]
  print(list.convertTo<String>()); // ['1', '2', '3', '3.1', '22.3']

  // parsing raw Json array of doubles to List<int>
  final intList = tryToList<int>('[1.5, 2.3, 3.4]');
  print(intList); // [1, 2, 3]

  // parsing raw Json to Map<String, dynamic>
  // note: you can also use the ConvertObject.toMap to avoid ambiguity.
  final userMap = toMap<String, dynamic>('''
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
  final walletBalance = toInt(userMap['wallet']);
  // OR
  // final walletBalance = userMap.getInt('wallet');
  // final walletBalance = ConvertObject.toInt(userMap['wallet']);
  print('user walletBalance: $walletBalance');

  // Example of using string extensions
  final userMail = toString1(userMap['email']);
  print('Is Valid Email: ${userMail.isValidEmail}');

  // Example of using HttpResStatus
  final status = 200.toHttpResStatus;
  print('Status: ${status.code} - ${status.desc}');
  print('Is Success: ${status.isSuccess}');
  print('Is Client Error: ${status.isClientError}');

  // quickly use normal date parsing.
  print('1997-08-12 00:00:00.000'.toDateTime);

  // parsing complex datetime formats.
  const dateStr1 = '2024-06-09T15:30:00Z';
  const dateStr2 = 'June 9, 2024 3:30 PM';
  const dateStr3 = 'Tuesday, June 11th, 2024 at 2:15 PM';

  print(dateStr1.toDateAutoFormat());
  print(dateStr2.toDateAutoFormat());
  print(dateStr3.toDateAutoFormat());

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
    }
  };

  // Convert the map to a formatted JSON string
  print(exampleMap.encodedJsonString);

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
      '1 Million list generated in: ${executionDuration.inMilliseconds} milliseconds');

  // Example of comparing two tasks execution time using the TimeUtils class.
  final durations = await TimeUtils.compareExecutionTimes(
    taskA: () {
      for (var i = 0; i < 100; i++) {
        List.generate(1000000, (index) => userMap);
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

  final doublyLinkedList = [1, 2, 3, 4].toDoublyLinkedList()
    ..add(5)
    ..removeAt(3);

  print(doublyLinkedList);

  final node = doublyLinkedList.findNode(1);
  print(node.data);

  print(doublyLinkedList.findNode(1));
  print(doublyLinkedList[1]); // [index] returns an element at specific index

  print(doublyLinkedList.toSet());
  print(doublyLinkedList.length);
  print(doublyLinkedList.head?.next);

  // loop over elements
  for (final e in doublyLinkedList) {
    print('e: $e');
  }

  // loop over nodes
  for (final node in doublyLinkedList.nodes) {
    print('Prev: ${node.prev}, Current: ${node.data}, Next: ${node.next}');
  }

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
    final parsedDate = dateStr.parseHttpDate();

    if (parsedDate != null) {
      print('Date string: "$dateStr" ($formatDescription)');
      print('Parsed DateTime: ${parsedDate.toIso8601String()}');
    } else {
      print('Date string: "$dateStr" ($formatDescription)');
      print('Parsing failed (DateTime is null)');
    }
    print('---');
  }
}

// Example enum used in the map
enum TimePeriod {
  day,
  week,
  month,
}
