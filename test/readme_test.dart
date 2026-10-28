/// Compiles and runs every Dart example in README.md.
///
/// Each README code block appears below verbatim, inside a test that runs
/// it. The first test fails when a README block has no copy here, and every
/// `print(...); // output` line in a block is an assertion: the printed
/// value must equal the comment, and the second test fails when a block's
/// output goes unchecked. Edit an example in both places, and the suite
/// proves the README still compiles and tells the truth.
@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  final readme = File('README.md').readAsStringSync();
  final blocks = RegExp(r'```dart\n([\s\S]*?)```')
      .allMatches(readme)
      .map((match) => match.group(1)!)
      .toList();

  /// The README block that contains [line].
  String block(String line) => blocks.singleWhere((b) => b.contains(line));

  test('every README Dart block is compiled by this file', () {
    final source = _normalize(File('test/readme_test.dart').readAsStringSync());
    expect(blocks, isNotEmpty);
    for (final readmeBlock in blocks) {
      expect(
        source.contains(_normalize(readmeBlock)),
        isTrue,
        reason:
            'Copy this README block into test/readme_test.dart:\n'
            '$readmeBlock',
      );
    }
  });

  test('every README output comment is compared with the output', () {
    final source = File('test/readme_test.dart').readAsStringSync();
    final compared = {
      for (final match in RegExp(
        r"_expectedPrints\(block\('([^']+)'\)\)",
      ).allMatches(source))
        block(match.group(1)!),
    };
    for (final readmeBlock in blocks) {
      final prints = readmeBlock
          .split('\n')
          .where((line) => line.trimLeft().startsWith('print('))
          .toList();
      for (final line in prints) {
        expect(
          _printLine.hasMatch(line),
          isTrue,
          reason: 'Write README prints as `print(...); // output`: $line',
        );
      }
      expect(
        prints.isEmpty || compared.contains(readmeBlock),
        isTrue,
        reason:
            'Compare the output of this block with '
            '_expectedPrints(block(...)):\n$readmeBlock',
      );
    }
  });

  test('a quick look', () async {
    final printed = await _prints(() {
      final config = {
        'db': {
          'host': 'localhost',
          'pool': {'size': '20'},
        },
        'tags': ['api', 'internal'],
      };

      print(config.getPath('db.pool.size')); // 20
      print(config.flatMap()['tags.1']); // internal
      print([1, 2, 3, 4, 5].chunks(2)); // [[1, 2], [3, 4], [5]]
      print('1h 30m'.parseDuration().inMinutes); // 90
      print(1234567.891.formatAsReadableNumber()); // 1,234,567.89
      print('invoice.pdf'.isPDF); // true
      print(DateTime(2024, 1, 31).addMonths(1)); // 2024-02-29 00:00:00.000
    });
    expect(printed, _expectedPrints(block('final config = {')));
  });

  test('debouncing and throttling', () async {
    final searched = <String>[];
    void search(String query) => searched.add(query);

    final debouncer = Debouncer(
      delay: const Duration(milliseconds: 300),
      maxWait: const Duration(seconds: 2),
    );

    void onQueryChanged(String query) => debouncer.run(() => search(query));

    // When the screen or service goes away:
    debouncer.dispose();

    expect(onQueryChanged, isA<void Function(String)>());
    expect(searched, isEmpty, reason: 'dispose cancels pending work');
  });

  test('bounded concurrency', () async {
    final files = ['a.txt', 'b.txt', 'c.txt', 'd.txt', 'e.txt'];
    // Later files finish first, so completion order differs from input.
    Future<String> upload(String file) => Future.delayed(
      Duration(milliseconds: 5 * (files.length - files.indexOf(file))),
      () => 'https://cdn.example/$file',
    );

    // Up to 4 uploads run at once; results come back in input order.
    final urls = await files.mapConcurrent(
      upload,
      parallelism: 4,
      preserveOrder: true,
    );

    expect(urls, files.map((file) => 'https://cdn.example/$file').toList());
  });

  test('streams without a reactive dependency', () async {
    final clicks = Stream.fromIterable(List.generate(10, (i) => i));
    final logLines = Stream.fromIterable(List.generate(250, (i) => 'line $i'));
    final prices = Stream.fromIterable([101.5, 99.0]);

    final limited = clicks.rateLimit(5, const Duration(seconds: 1));
    final batches = logLines.bufferCount(100);
    final latest = prices.withLatestValue();

    expect(await limited.toList(), [0, 1, 2, 3, 4]);
    expect((await batches.toList()).map((batch) => batch.length), [
      100,
      100,
      50,
    ]);
    expect(await latest.toList(), [101.5, 99.0]);
  });

  test('soft timeouts', () async {
    final shown = <String>[];
    var bannerShown = false;
    Future<String> fetchReport() =>
        Future.delayed(const Duration(milliseconds: 10), () => 'report');
    void show(String report) => shown.add(report);
    void showSlowNetworkBanner() => bannerShown = true;

    try {
      final report = await TimeUtils.runWithTimeout(
        task: fetchReport,
        timeout: const Duration(seconds: 5),
      );
      show(report);
    } on TimeoutException {
      showSlowNetworkBanner();
    }

    expect(shown, ['report']);
    expect(bannerShown, isFalse);
  });

  test('nested maps', () async {
    final printed = await _prints(() {
      final payload = {
        'user': {
          'name': 'Ada',
          'langs': ['dart', 'go'],
        },
      };

      print(payload.getPath('user.langs[1]')); // go
      final flat = payload.flatMap();
      print(flat); // {user.name: Ada, user.langs.0: dart, user.langs.1: go}
      print(flat.unflatten()); // {user: {name: Ada, langs: [dart, go]}}
    });
    expect(printed, _expectedPrints(block('final payload = {')));
  });

  test('dates that follow the calendar', () async {
    final printed = await _prints(() {
      final saturday = DateTime(2024, 3, 9, 10, 30);
      print(saturday.addDays(1)); // 2024-03-10 10:30:00.000
      print(saturday.nextWeek); // 2024-03-16 10:30:00.000
      print(saturday.isSameDayAs(DateTime(2024, 3, 9, 23, 59))); // true

      final friday = DateTime(2024, 6, 14);
      print(friday.addBusinessDays(1)); // 2024-06-17 00:00:00.000

      final utcNoon = DateTime.utc(2024, 5, 17, 12);
      print(utcNoon.startOfMonth); // 2024-05-01 00:00:00.000Z
    });
    expect(printed, _expectedPrints(block('final saturday = ')));
  });

  test('the README date claims hold', () {
    final moment = DateTime(2024, 3, 10, 15, 45);
    expect(moment.floorTo(const Duration(days: 1)), moment.startOfDay);
    final utc = DateTime.utc(2024, 3, 10, 15);
    expect(utc.startOfDay.isUtc && utc.addDays(1).isUtc, isTrue);
  });

  test('formatting with intl', () async {
    final printed = await _prints(() {
      print(1234.5.formatAsCurrency(locale: 'en_US')); // $1,234.50
      print(DateTime(2024, 5, 17).format('yMMMd', 'en_US')); // May 17, 2024
      print(1.pluralize(other: 'files', one: 'file', locale: 'en')); // file
      print(3.toOrdinal()); // 3rd
    });
    expect(printed, _expectedPrints(block('formatAsCurrency')));
  });
}

/// Trims every line, collapses inner whitespace, and drops blank lines, so
/// indentation inside a test does not hide a copied block.
String _normalize(String code) => code
    .split('\n')
    .map((line) => line.trim().replaceAll(RegExp(r'\s+'), ' '))
    .where((line) => line.isNotEmpty)
    .join('\n');

/// A `print(...); // output` line; group 1 is the promised output.
final _printLine = RegExp(r'^\s*print\(.*\);\s*// (.*)$', multiLine: true);

/// The outputs that `print(...); // output` lines in [block] promise.
List<String> _expectedPrints(String block) => [
  for (final match in _printLine.allMatches(block)) match.group(1)!,
];

/// Runs [body] and returns everything it printed.
Future<List<String>> _prints(FutureOr<void> Function() body) async {
  final printed = <String>[];
  await runZoned(
    () async => body(),
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) => printed.add(line),
    ),
  );
  return printed;
}
