# Migration Guide (v6)

Version 6.0.0 is a major release that refactors all conversion logic into a
specialized standalone package: [`convert_object`](https://pub.dev/packages/convert_object).
`dart_helper_utils` now exports this package, ensuring a cleaner architecture.

## 💥 Breaking Changes

### 1. Class Renaming: `ConvertObject` → `Convert`
The static utility class `ConvertObject` has been renamed to `Convert` to be more concise.

| v5 (Old)                        | v6 (New)                  |
|:--------------------------------|:--------------------------|
| `ConvertObject.toInt(...)`      | `Convert.toInt(...)`      |
| `ConvertObject.toBool(...)`     | `Convert.toBool(...)`     |
| `ConvertObject.toDateTime(...)` | `Convert.toDateTime(...)` |
| `ConvertObject.tryToMap(...)`   | `Convert.tryToMap(...)`   |

### 2. Method Renaming: `toString1` → `string`
To avoid confusion with the standard Dart `toString()`, the static string conversion method has been renamed.

| v5 (Old)                         | v6 (New)                |
|:---------------------------------|:------------------------|
| `ConvertObject.toString1(value)` | `Convert.string(value)` |

### 3. Top-level Functions Renamed
The top-level conversion functions have been renamed to avoid conflicts and improve clarity. They are now prefixed with `convert` or `tryConvert`.

| v5 (Old)             | v6 (New)                    |
|:---------------------|:----------------------------|
| `toString1(val)`     | `convertToString(val)`      |
| `tryToString(val)`   | `tryConvertToString(val)`   |
| `toNum(val)`         | `convertToNum(val)`         |
| `tryToNum(val)`      | `tryConvertToNum(val)`      |
| `toInt(val)`         | `convertToInt(val)`         |
| `tryToInt(val)`      | `tryConvertToInt(val)`      |
| `toDouble(val)`      | `convertToDouble(val)`      |
| `tryToDouble(val)`   | `tryConvertToDouble(val)`   |
| `toBigInt(val)`      | `convertToBigInt(val)`      |
| `tryToBigInt(val)`   | `tryConvertToBigInt(val)`   |
| `toBool(val)`        | `convertToBool(val)`        |
| `tryToBool(val)`     | `tryConvertToBool(val)`     |
| `toDateTime(val)`    | `convertToDateTime(val)`    |
| `tryToDateTime(val)` | `tryConvertToDateTime(val)` |
| `toUri(val)`         | `convertToUri(val)`         |
| `tryToUri(val)`      | `tryConvertToUri(val)`      |
| `toMap<K,V>(val)`    | `convertToMap<K,V>(val)`    |
| `tryToMap<K,V>(val)` | `tryConvertToMap<K,V>(val)` |
| `toSet<T>(val)`      | `convertToSet<T>(val)`      |
| `tryToSet<T>(val)`   | `tryConvertToSet<T>(val)`   |
| `toList<T>(val)`     | `convertToList<T>(val)`     |
| `tryToList<T>(val)`  | `tryConvertToList<T>(val)`  |
| `toType<T>(val)`     | `convertToType<T>(val)`     |
| `tryToType<T>(val)`  | `tryConvertToType<T>(val)`  |

### 4. Exception Changes
`ParsingException` has been replaced by `ConversionException`.

| Feature             | v5 (Old)           | v6 (New)              |
|:--------------------|:-------------------|:----------------------|
| **Exception Class** | `ParsingException` | `ConversionException` |
| **Error Context**   | `e.parsingInfo`    | `e.context`           |

**Migration Example:**
```dart
try {
  Convert.toInt("invalid");
} catch (e) {
  if (e is ConversionException) { // Was ParsingException
    print(e.context); // Was e.parsingInfo
  }
}
```

### 5. Map Extension Parameter Changes
The `altKeys` parameter in Map extension methods has been renamed to `alternativeKeys` for clarity.

```dart
// v5
map.getString('key', altKeys: ['k2']);

// v6
map.getString('key', alternativeKeys: ['k2']);
```

### 6. Removed Object Extensions
The type-checking getters on `Object?` have been removed to keep the API clean. Use the `tryConvert` functions or standard Dart checks.

| v5 (Old)       | v6 (Replacement)                  |
|:---------------|:----------------------------------|
| `obj.isDouble` | `tryConvertToDouble(obj) != null` |
| `obj.isInt`    | `tryConvertToInt(obj) != null`    |
| `obj.isNum`    | `tryConvertToNum(obj) != null`    |
| `obj.isNull` / `obj.isNotNull` | `obj == null` / `obj != null` |

### 7. List/Set `convertTo` Changes
The `.convertTo<T>()` extension method has been removed from `List` to avoid ambiguity with `map`. It remains available on `Set`.

| v5 (Old)                | v6 (New)                                                  |
|:------------------------|:----------------------------------------------------------|
| `list.convertTo<int>()` | `convertToList<int>(list)` or `Convert.toList<int>(list)` |
| `set.convertTo<int>()`  | `set.convertTo<int>()` (Unchanged)                        |

### 8. Behavior Differences (Defaults)
- `tryToBool` returns `null` for unknown values. Use `defaultValue: false` or
  `?? false` if you want a false fallback.
- Numeric parsing is **lenient** by default (commas/spaces/underscores and
  `(123)` → `-123`). You can enforce strict parsing:
  ```dart
  Convert.configure(
    ConvertConfig(
      numbers: const NumberOptions(strictParsing: true),
    ),
  );
  ```
- URI parsing auto-detects emails and phone numbers. You can disable either:
  ```dart
  Convert.configure(
    ConvertConfig(
      uri: const UriOptions(
        detectEmails: false,
        detectPhoneNumbers: false,
      ),
    ),
  );
  ```
- `tryToType<T>` returns `null` for unsupported target types. Use
  `Convert.toType<T>` if you need exceptions.
- `toDateTime`/`tryToDateTime` now accept numeric epoch values (seconds or
  milliseconds).

### 9. Iterable/Map Cleanup (collection replacements)
Duplicate iterable/map helpers were removed in favor of `package:collection`.
Add:

```dart
import 'package:collection/collection.dart';
```

Common replacements:

| Removed | Replacement |
|:---|:---|
| `iter.firstOrNull` | `iter.firstOrNull` (from `collection`) |
| `iter.lastOrNull` | `iter.lastOrNull` (from `collection`) |
| `iter.firstWhereOrNull(...)` | `iter.firstWhereOrNull(...)` (from `collection`) |
| `iter.whereNotNull()` | `iter.whereNotNull()` (from `collection`) |
| `iter.mapIndexed(...)` | `iter.mapIndexed(...)` (from `collection`) |
| `iter.forEachIndexed(...)` | `iter.forEachIndexed(...)` (from `collection`) |
| `iter.whereIndexed(...)` | `iter.whereIndexed(...)` (from `collection`) |
| `groupBy(iter, ...)` | `groupBy(iter, ...)` (from `collection`) |
| `iter.sortedDescending()` | `iter.sorted((a, b) => b.compareTo(a))` |
| `iter.count((e) => ...)` | `iter.where((e) => ...).length` |
| `map.update(...)` (extension) | `Map.update(...)` (SDK) |
| `map.isEqual(other)` | `const MapEquality().equals(map, other)` |

For deep equality across nested collections:

```dart
const DeepCollectionEquality().equals(a, b);
```

### 10. Roman Numerals Moved to `convert_object`
Roman numeral helpers now live in `convert_object`:

```dart
import 'package:convert_object/convert_object.dart';

final roman = 42.toRomanNumeral(); // "XLII"
final value = 'XLII'.asRomanNumeralToInt; // 42
print(romanNumerals); // Map<int, String>
```

### 11. `TimeUtils.throttle` API Update

`TimeUtils.throttle` now returns a callable object with `cancel()` and `dispose()`,
and the parameter order has changed.

**Old usage:**

```dart
final throttled = TimeUtils.throttle(
  duration: Duration(seconds: 1),
  function: () => print('tick'),
);
```

**New usage:**

```dart
final throttled = TimeUtils.throttle(
  () => print('tick'),
  Duration(seconds: 1),
  trailing: true,
);
throttled();
```

### 12. Pagination Helpers Removed

The `Pagination` helpers (`Paginator`, `AsyncPaginator`, `InfinitePaginator`)
have been removed from `dart_helper_utils` to keep the package focused on core utilities.
If you need pagination logic, we recommend using dedicated packages like:

- `infinite_scroll_pagination` (Flutter)
- `very_good_infinite_list` (Flutter)
- Or implementing a custom solution using `Debouncer` and `CancelableOperation` if needed.

### 13. DoublyLinkedList Moved Out

`DoublyLinkedList` and `toDoublyLinkedList` have been removed from
`dart_helper_utils`. Use the standalone package instead:

https://pub.dev/packages/doubly_linked_list

### 14. Date Utils Rename

`httpFormat` is now `httpDateFormat` on `DateTime`.

### 15. String Validation Intent

`isNumeric` and `isAlphabet` are ASCII-only and trim whitespace before checking.
`isBool` is case-insensitive and trims whitespace.

### 16. Country/Timezone Data Removed

The static country/timezone datasets and helpers were removed to keep
`dart_helper_utils` lightweight.

Removed:

- `DHUCountry`, `DHUTimezone`, `CountrySearchService`
- `getRawCountriesData`, `getTimezonesRawData`, `getTimezonesList`

Use a dedicated package or API that fits your use case for up-to-date data.

### 17. String Similarity Moved Out

String similarity logic has been moved to a specialized standalone package: [`string_search_algorithms`](https://pub.dev/packages/string_search_algorithms).

**Removed:**
- `StringSimilarity` class
- `SimilarityAlgorithm` enum
- `String.similarityTo` extension and related methods.
- `String.compareWith` extension.

**Migration:**
Add the new package to your `pubspec.yaml`:

```yaml
dependencies:
  string_search_algorithms: ^1.0.0
```

And update your imports:

```dart
import 'package:string_search_algorithms/string_search_algorithms.dart';
```

Then replace `compareWith` with the new extension or facade:

```dart
// Old:
// final score = 'kitten'.compareWith(
//   'sitting',
//   SimilarityAlgorithm.levenshteinDistance,
// );

// New:
final score = 'kitten'.similarityTo(
  'sitting',
  algorithm: SimilarityAlgorithm.levenshtein,
);
```

If you used `StringSimilarityConfig`, construct an engine with
`SimilarityOptions` instead:

```dart
final engine = StringSimilarityEngine(
  options: SimilarityOptions(
    normalization: NormalizationOptions(
      enabled: true,
      trimWhitespace: true,
      removeSpaces: false,
      toLowerCase: true,
      removeSpecialChars: false,
      removeAccents: false,
      preProcessor: (s) => s,
      postProcessor: (s) => s,
    ),
    cache: CacheOptions(
      enabled: true,
      normalizedCapacity: 1000,
      bigramCapacity: 1000,
      ngramCapacity: 1000,
    ),
    algorithms: AlgorithmOptions(
      jaroWinklerPrefixScale: 0.1,
      ngramSize: 3,
      stemTokens: false,
    ),
  ),
);

final scoreWithOptions = engine.compare(
  'kitten',
  'sitting',
  algorithm: SimilarityAlgorithm.levenshtein,
);
```

Note: `SimilarityAlgorithm.levenshteinDistance` is now
`SimilarityAlgorithm.levenshtein`. Other algorithm names are unchanged.

### 18. Nullable List `tryRemoveWhere` Signature

`tryRemoveWhere` now accepts a predicate and performs removal.

```dart
// v5
list.tryRemoveWhere(0); // did nothing

// v6
list.tryRemoveWhere((e) => e.isEven);
```

### 19. Percentile Range (0-100)

Percentile helpers now expect `0..100` instead of `0..1`.

```dart
// v5
values.percentile(0.5);

// v6
values.percentile(50);
```

### 20. `Map.setIfMissing` Key Semantics

`setIfMissing` now checks key presence instead of null values. It will not
overwrite existing entries (even if the value is null).

### 21. Random Helper Validation

`Iterable.getRandom` throws `StateError` on empty iterables. `randomInRange`
throws `ArgumentError` when `min > max`. `num.getRandom` / `num.random` throw
`RangeError` when the upper bound is `<= 0`.

## ✨ New Features

### Fluent API
You can now use the `.convert` getter on any object for a fluent, chainable API.

```dart
import 'package:dart_helper_utils/dart_helper_utils.dart';

// Fluent Style
"123".convert.toInt(); 
data.convert.fromMap('user').fromMap('age').toIntOr(0);
```

### Improved Enum Support
Dedicated methods for Enum conversion.

```dart
// Convert string/int to Enum
Convert.toEnum(value, parser: MyEnum.values.parser);
```

### Global Configuration
You can now configure global defaults (like locale or error hooks) using `Convert.configure`.

```dart
Convert.configure(
  ConvertConfig(
    locale: 'en_US',
    onException: (e) => log(e.toString()),
  ),
);
```

### Kotlin-style Scope Functions
Added `let` and `letOr` extensions for cleaner null handling and scoping.

```dart
final result = nullableValue?.let((v) => calculate(v));
```

### Utility Additions
More production-focused helpers were added to round out the core extensions:

- **Date/Time:** `DateTime.copyWith`, `isSameYearAs`, `isSameMonthAs`,
  `clampBetween`, `Duration.toClockString`, `Duration.toHumanShort`,
  `String.parseDuration`.
- **Collections:** `Iterable.windowed`, `Iterable.pairwise`, `Map.deepMerge`,
  `Map.unflatten`, `Map.getPath`, `Map.setPath`.
- **URIs:** `Uri.withQueryParameters`, `mergeQueryParameters`,
  `removeQueryParameters`, `appendPathSegment(s)`, `normalizeTrailingSlash`.
- **Strings:** `String.normalizeWhitespace`, `String.slugify`.

If you were relying on "time ago" helpers, use
[`timeago`](https://pub.dev/packages/timeago) instead.

# Migration Guide (v4)

This guide explains the major changes in version 4 provides step-by-step instructions to
update your code.

---

### 1. Adjust for the New `BasePaginator` and Lifecycle Events

- **Centralized Logic:**  
  v4 introduces a `BasePaginator<T>` class that centralizes shared logic such as debouncing and disposal checks.  
  **Action:**
    - If you previously subclassed `Paginator` directly, consider extending either `BasePaginator<T>` or the new
      `Paginator<T>`.
    - Override the `onPageChanged` method if you need custom behavior on page transitions. This replaces any older
      custom hooking mechanisms around `goToPage`.

---

### 2. Handle Casting and Transformations

- **Transformation Methods:**  
  Earlier versions might have returned raw lists or used a different caching mechanism for methods like `where()` or
  `sort()`.  
  **Action:**
    - In v4, these methods now return fully instantiated `Paginator<T>` objects, stored internally in a time-based
      `_transformCache`.
    - Update your code to work with the returned `Paginator<T>` instances instead of accessing raw transformation
      results.

---

### 3. Use of `CancelableOperation` in `AsyncPaginator` (Optional)

- **Avoid Overlapping Requests:**  
  The new implementation uses `CancelableOperation` to deduplicate and cancel overlapping fetch requests.  
  **Action:**
    - Set `autoCancelFetches` to `true` in your `PaginationConfig` if you want to prevent concurrent fetches.
    - If you prefer the old behavior (allowing multiple simultaneous requests), set `autoCancelFetches` to `false`.

---

### 4. Infinite Paginator Changes

- **Unified Infinite Scrolling:**  
  The `InfinitePaginator` now supports both page-based and cursor-based approaches via factory constructors.  
  **Action:**
    - Replace any legacy infinite scroll classes or custom implementations with either `InfinitePaginator.pageBased()`
      or `InfinitePaginator.cursorBased()`.
    - Adapt any direct usage of pagination keys to match the new factory constructor signatures.

---

### 5. Updated Number Extensions for Delay Methods

- **Specific Duration Methods:**  
  The generic `delay()` method has been replaced by more specific duration-based delay methods.

  **Action:** Replace old delay methods as follows:
    - Replace await `2.delay();` and `await 2.secDelay;` with `await 2.secondsDelay();`
    - Replace await `5.minDelay;` with `await 5.minutesDelay();`
    - Replace await `1.daysDelay;` with `await 1.daysDelay();`
    - And so on for other time units.

  Additionally, if you previously used a delay with a callback:

  ```dart
  // Old:
  await 2.delay(() => someFunction());
  
  // New:
  final result = await 2.secondsDelay(() => someFunction());
  ```

---

### 6. Analytics (Optional)

- **Tracking Metrics:**  
  If you need to track metrics (such as page loads, errors, and cache hits), add the `PaginationAnalytics` mixin to your
  custom paginator class.

  **Action:** Incorporate the mixin where needed to log metrics according to your application requirements.

---

### 7. Testing and Disposal Behavior

- **No-Op After Disposal:**  
  In v4, methods such as `goToPage` are designed to be no-ops (instead of throwing exceptions) after the paginator is
  disposed. This ensures that lifecycle streams remain silent post-disposal.

  **Action:**

    - Update your tests to reflect this behavior.
    - If your code previously expected an exception after disposal, refactor it to handle no-ops instead.

- **Review Your Tests:**  
  Confirm that your existing tests pass. Update any tests that reference legacy method names, class hierarchies, or
  disposal behavior.

## Migration Guide (v3)

### Breaking Changes

1. **String Extensions:**
    - Removed deprecated `toDateTime` method
    - Use `toDateFormatted` or `toDate` instead

2. **DateTime Extensions:**
    - Removed deprecated `format` method
    - Use `formatted` instead
    - Added stricter type checking for date operations

## Migration Guide (v2)

### 1. Date and Time Parsing

- **`try/toDateWithFormat` renamed to `try/toDateFormatted`:**
    - **Action:** Update all instances of `try/toDateWithFormat` in your code to `try/toDateFormatted`.

- **`dateFormat` on String is now a method with an optional `locale` parameter:**
  This change gives you more control over the formatting process, allowing you to specify the locale explicitly for
  accurate results.
    - **Old Usage:**
      ```dart
      String formattedDate = '2024-06-10'.dateFormat; // Used default or current locale
      ```
    - **New Usage:**
      ```dart
      String formattedDate = '2024-06-10'.dateFormat(); // Uses default locale
      String formattedDateUS = '2024-06-10'.dateFormat('en_US'); // Explicitly uses US locale
      ```

### 2. `firstDayOfWeek` and `lastDayOfWeek`

These methods now have an optional `startOfWeek` parameter to customize the first day of the week. The default value is
`DateTime.monday`.

**Old Usage:**

```dart

DateTime now = DateTime.now();
DateTime firstDayOfWeek = now.firstDayOfWeek;
DateTime lastDayOfWeek = now.lastDayOfWeek;
```

**New Usage:**

```dart

DateTime now = DateTime.now();
DateTime firstDayOfWeek = now.firstDayOfWeek(); // Defaults to Monday
DateTime lastDayOfWeek = now.lastDayOfWeek(); // Defaults to Monday

// Customize start of week (e.g., Sunday)
DateTime firstDayOfWeekSunday = now.firstDayOfWeek(startOfWeek: DateTime.sunday);
```

### 3. Map Methods

- **`flatJson` renamed to `flatMap`:** If you were using the `flatJson` method on `Map<String, dynamic>`, update your
  code to use `flatMap` instead. The functionality has been enhanced to handle arrays, circular references, and provide
  an option to exclude arrays.
- **`makeEncodable` and `safelyEncodedJson` renamed:** The `makeEncodable` and `safelyEncodedJson` methods on
  `Map<K, V>` have been renamed to `encodableCopy` and `encodedJsonString`, respectively. Additionally, an issue where
  sets were not correctly converted to JSON-encodable lists has been fixed.

### 4. Other Breaking Changes

Review the [changelog](https://github.com/omar-hanafy/dart_helper_utils/blob/main/CHANGELOG.md#200) for any other minor
breaking changes and update your code accordingly.

### Troubleshooting

If you encounter any issues during the migration process please fill
an [issue here.](https://github.com/omar-hanafy/dart_helper_utils/issues)
