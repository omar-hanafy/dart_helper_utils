import 'package:dart_helper_utils/dart_helper_utils.dart';

Future<void> main() async {
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
  final user = toMap<String, dynamic>(rawJson.decode());

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
      await 5.secDelay;
      return 'Completed';
    },
    timeout: const Duration(seconds: 3),
  );
  print('Result: $result');
}
