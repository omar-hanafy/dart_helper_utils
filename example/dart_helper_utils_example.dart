import 'package:dart_helper_utils/dart_helper_utils.dart';

Future<void> main() async {
  // [1, 2, 3]
  print(tryToList<int>('[1, 2, 3]'));

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
  final (durationA, durationB) = await TimeUtils.compareExecutionTimes(
    taskA: () {
      for (var i = 0; i < 100; i++) {
        List.generate(1000000, (index) => user);
      }
    },
    taskB: () async => 2.secDelay,
  );

  print(
    'TaskA took ${durationA.inMilliseconds} ms, TaskB took ${durationB.inMilliseconds} ms',
  );

  final result = await TimeUtils.runWithTimeout(
    task: () async {
      await 1.secDelay;
      return 'Completed';
    },
    timeout: const Duration(seconds: 3),
  );
  print('Result: $result');
}
