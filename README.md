[![dart_helper_utils logo](https://raw.githubusercontent.com/omar-hanafy/dart_helper_utils/main/logo.svg)](https://pub.dev/packages/dart_helper_utils)

[![pub package](https://img.shields.io/pub/v/dart_helper_utils)](https://pub.dev/packages/dart_helper_utils)

A batteries-included utility package for Dart. One import gives you type-safe
conversions, ergonomic extensions, a serious debouncer, stream superpowers,
and the APIs you already know from [`convert_object`](https://pub.dev/packages/convert_object), `collection`, and `intl`.

- Repository: https://github.com/omar-hanafy/dart_helper_utils
- Full API: https://pub.dev/documentation/dart_helper_utils/latest/dart_helper_utils/
- Migration guide: https://github.com/omar-hanafy/dart_helper_utils/blob/main/migration_guides.md

## Installation

```yaml
dependencies:
  dart_helper_utils: ^<latest_version>
```

```dart
import 'package:dart_helper_utils/dart_helper_utils.dart';
```

## At a glance

```dart
// Type-safe map extraction, collection helpers, and intl formatting
// all from a single import.
final map = {'name': 'Omar', 'count': '42', 'items': [1, 2, 3]};
print(map.getString('name'));                  // Omar
print(map.getInt('count'));                    // 42
print(map.getList<int>('items').firstOrNull);  // 1
print(1234567.89.formatAsReadableNumber());    // 1,234,567.89
print('invoice.pdf'.isPDF);                    // true
```

## Why reach for it

### One import, not five

Everything below is available from the single package import:

- Type-safe conversions from the re-exported [`convert_object`](https://pub.dev/packages/convert_object)
- `package:collection` (`firstOrNull`, `groupBy`, `mapIndexed`, ...)
- `intl` essentials (`DateFormat`, `NumberFormat`, `Bidi`, `Intl`)
- dozens of focused extensions and helpers from this package itself

No import soup, no glue code.

### A debouncer that is actually complete

Leading or trailing execution, a `maxWait` ceiling, pause and resume,
a state stream for observability, and optional execution history for debugging.

```dart
final debouncer = Debouncer(
  delay: const Duration(milliseconds: 300),
  maxWait: const Duration(seconds: 2),
);

void onSearchChanged(String q) =>
    debouncer.run(() => runSearch(q));

// Screen pauses:
debouncer.pause();
// Resumes later:
debouncer.resume();

// Optional observability.
debouncer.stateStream.listen(print);
```

### Stream superpowers, no reactive dependency

```dart
// Hold events until you are ready for them.
final paused = sensorStream.asPausable();

// Cap a noisy source at 5 events per second.
final safe = eventStream.rateLimit(5, const Duration(seconds: 1));

// Group events into fixed-size or time-based batches.
final batched = logStream.bufferCount(100);
final windowed = logStream.window(const Duration(seconds: 1));

// Behaviour-subject semantics: late subscribers see the last value.
final replay = priceStream.withLatestValue();
```

### Bounded concurrency and soft timeouts

```dart
// Run at most 4 uploads at once, results in completion order.
final urls = await files.mapConcurrent(upload, parallelism: 4);

// Soft timeout: the original task keeps running in the background.
try {
  final report = await TimeUtils.runWithTimeout(
    task: fetchReport,
    timeout: const Duration(seconds: 5),
  );
} on TimeoutException {
  showSlowNetworkBanner();
}
```

### Deep map utilities for config-heavy apps

```dart
final nested = {
  'user': {'name': 'Omar', 'roles': ['admin', 'editor']},
};

final flat = nested.flatMap();
// {user.name: Omar, user.roles.0: admin, user.roles.1: editor}

print(flat.unflatten()); // round-trips back to nested

final payload = {'users': [{'name': 'A'}, {'name': 'B'}]};
print(payload.getPath('users[1].name')); // B
```

## Also in the box

Everyday sugar that you would otherwise write by hand: case conversion,
`slugify`, `parseDuration`, email and string masking, MIME checks
(`isPDF`, `isImage`, `isFont`), date helpers (`isBetween`, `addBusinessDays`,
`daysInMonth`), Intl formatters (`formatAsCurrency`, `formatAsCompact`,
`toOrdinal`, `pluralize`), URI builders (`rebuild`, `mergeQueryParameters`,
`appendPathSegment`), and `Iterable<num>` statistics (`mean`, `median`,
`percentile`, `standardDeviation`).

Browse the full API: https://pub.dev/documentation/dart_helper_utils/latest/

## Migration notes

- v6 moved conversion logic into [`convert_object`](https://pub.dev/packages/convert_object), which is re-exported here.
- Duplicate iterable and map helpers were removed in favor of
  `package:collection`, which is now also re-exported.
- Old JSON helpers like `safelyEncodedJson` are now `toJsonString(...)` or
  `encodeWithIndent` from [`convert_object`](https://pub.dev/packages/convert_object).

Full guide: https://github.com/omar-hanafy/dart_helper_utils/blob/main/migration_guides.md
