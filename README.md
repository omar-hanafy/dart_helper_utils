# dart_helper_utils

Dart utilities and ergonomic extensions with type-safe conversions via the
re-exported `convert_object` package.

Repository: https://github.com/omar-hanafy/dart_helper_utils
Package: https://pub.dev/packages/dart_helper_utils

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  dart_helper_utils: ^6.0.0
```

## Import

```dart
import 'package:dart_helper_utils/dart_helper_utils.dart';
```

## Highlights

- **Type-safe conversions** (from `convert_object`) with configurable strictness.
- **Collections**: chunking, windowing, partitioning, and safe map/list helpers.
- **Strings**: case conversion, slugify, parsing, validation, and masking.
- **Numbers**: formatting via `intl`, file size helpers, and HTTP status helpers.
- **Date/Time**: rounding, comparisons, and HTTP date formatting.
- **Async**: retries, timeouts, concurrency throttling, debouncing/throttling.
- **Streams**: retries and safe controller additions.
- **Raw data**: HTTP status messages, CSS colors, and suffix maps.

## Quick start

```dart
import 'package:dart_helper_utils/dart_helper_utils.dart';

void main() async {
  final json = '{"count": "42"}';
  final data = convertToMap<String, Object?>(json);
  final count = convertToInt(data['count']);
  print(count); // 42

  final slug = 'Hello, World!'.slugify();
  print(slug); // hello-world

  final chunked = [1, 2, 3, 4, 5].chunks(2);
  print(chunked); // [[1, 2], [3, 4], [5]]

  final results = await [1, 2, 3].mapConcurrent(
    (value) async => value * 2,
    parallelism: 2,
  );
  print(results); // [2, 4, 6] (completion order)
}
```

## API overview

### Conversions (re-exported from `convert_object`)

- `convertToInt(value, {defaultValue})` -> `int` (throws `ConversionException`)
- `tryConvertToInt(value)` -> `int?`
- `convertToDateTime(value, {format, locale})` -> `DateTime`
- `Convert.toInt(value, {defaultValue})` -> `int`
- `Convert.configure(ConvertConfig)` -> `void`

### Strings

- `String.toCamelCase`, `toPascalCase`, `toSnakeCase`, `toKebabCase`
- `String.slugify({separator})`
- `String.parseDuration()` -> `Duration`
- `String.maskEmail`, `String.mask({visibleStart, visibleEnd})`
- `String.normalizeWhitespace()`, `String.removeEmptyLines`

### Collections

- `Iterable<E>.chunks(size)` -> `List<List<E>>`
- `Iterable<E>.windowed(size, {step, partials})`
- `Iterable<E>.mapConcurrent(action, {parallelism})` (completion order)
- `Iterable<E>.concatWithSingleList(iterable)`
- `Iterable<E>.concatWithMultipleList(iterables)`
- `Map<String, Object?>.getPath(path, {delimiter})`
- `Map<String, Object?>.setPath(path, value, {delimiter, parseIndices})`
- `Map<String, Object?>.deepMerge(other)`

### Date and time

- `DateTime.httpDateFormat` -> `String`
- `DateTime.isBetween(start, end, {inclusiveStart, inclusiveEnd, ignoreTime, normalize})`
- `DateTime.roundTo(duration)`
- `Duration.toClockString()`
- `Duration.toHumanShort()`

### Async helpers

- `Future<T>.minWait(duration)`
- `Future<T>.timeoutOrNull(timeout)`
- `Future<T> Function().retry({retries, delay, retryIf})`
- `Iterable<Future<T> Function()>.waitConcurrency({concurrency})` (completion order)

### Streams

- `StreamController<T>.safeAdd(event)`
- `Stream<T>.retry({retryCount, delayFactor, shouldRetry})`

### HTTP helpers

- `num.isSuccessCode`, `num.isClientErrorCode`, `num.isServerErrorCode`
- `num.statusCodeRetryDelay`
- `num.toHttpStatusUserMessage`

### Raw data

- `greekNumberSuffixes` -> `List<String>`
- `httpStatusMessages` -> `Map<int, String>`
- `cssColorNamesToArgb` -> `Map<String, int>`

## Notes

- `mapConcurrent` and `waitConcurrency` return results in completion order.
- `TimeUtils.runWithTimeout` returns a `TimeoutException` when the timeout
  fires, but the original task keeps running in the background.

## Examples

### Conversions

```dart
print(convertToInt('42')); // 42
print(tryConvertToInt('x')); // null
```

### DateTime.isBetween

```dart
final start = DateTime(2024, 1, 1);
final end = DateTime(2024, 1, 2);
print(DateTime(2024, 1, 1).isBetween(start, end)); // true
print(DateTime(2024, 1, 2).isBetween(start, end)); // false
```

### String.parseDuration

```dart
print('1h 30m'.parseDuration()); // 1:30:00.000000
```
