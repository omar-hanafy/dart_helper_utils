# CHANGELOG

## 6.0.0-dev.2

- Pre-release for v6.
- Repository automation and CI/CD workflows.
- Update convert_object dependency to ^1.0.1.

### Breaking changes
- Conversion APIs moved to the dedicated
  [convert_object](https://pub.dev/packages/convert_object) package and are
  re-exported here. `ConvertObject` → `Convert`, top-level conversion functions
  renamed to `convertTo*` / `tryConvertTo*`, and `ParsingException` replaced by
  `ConversionException`.
- Removed DHU duplicate extensions (object parsing checks, null checks, iterable
  helpers like `firstOrNull`/`groupBy`/`mapIndexed`, map `isEqual`/`update`,
  string `isNullOrWhiteSpace`, etc.). Use SDK or `package:collection` instead.
- `TimeUtils.throttle` signature changed; now returns a callable object with
  `cancel()` / `dispose()` and supports leading/trailing options.
- `BasePaginator.goToPage` now applies immediately (no internal debounce).
- `httpFormat` renamed to `httpDateFormat`.
- Roman numeral helpers moved to `convert_object`.
- `DoublyLinkedList` removed from DHU; use `doubly_linked_list` package.
- Removed static country/timezone datasets to keep DHU lightweight. For
  up-to-date data, use a dedicated package or API that fits your use case.
- HTTP status maps drop non‑standard 499/599 and mark 306 as unused.

### New/updated
- Throttling utilities (`Throttler`, `ThrottledCallback`).
- String validation now trims input; `isBool` is case‑insensitive.

### Migration
- Updated `migration_guides.md` with v6 migration notes.

## 5.5.0

- Enum conversion: `ConvertObject.toEnum<T extends Enum>()` / `tryToEnum<T extends Enum>()` + top-level mirrors.
- Collection extensions: `getEnum`/`tryGetEnum` for `Map` and `Iterable` (nullable and non-nullable).
- Helpers: `EnumParsers` (`byName`, `fromString`, `byNameOrFallback`, `byNameCaseInsensitive`, `byIndex`) and `List<T extends Enum>` shortcuts (`.parser`, `.parserWithFallback`, `.parserCaseInsensitive`, `.parserByIndex`).
- Safer `try*` conversions via `_convertObject` improvements; enum APIs constrained to `T extends Enum`.

## 5.4.1

Improved String.toDateAutoFormat docs (parsing order, locale, time zones) with examples. Refactored implementation for
better normalization and locale-aware disambiguation.
Added documentation_rules.md for module docs standards.

## 5.4.0

- Enhanced ParsingException to provide comprehensive debugging information with structured argument maps and filtered output.

## 5.3.0

- Reintroduced `Coordinates` typedef with serialization support (to/from JSON)

## 5.2.2

- Added public methods `firstValueForKeys` and `firstElementForIndices` to Map and Iterable extensions for accessing values with fallback options.

## 5.2.1

- exported exception classes.

## 5.2.0
- Made the encode on object returns String instead of dynamic, to prevent confusion.
- Added Kotlin-style `let` extension for `T` and `T?` types to simplify value transformations and null-safe chaining.

## 5.1.0
- Added new global randomBool, randomInt, and randomDouble
- Updated the StringSimilarity: 
  - Focused on six key algorithms with enhanced accuracy (to see demo, you can view my [enefty_icons_preview website](https://omar-hanafy.github.io/enefty-icons/#/) for the [enefty_icons](https://pub.dev/packages/enefty_icons) package).
  - Improved caching and performance for large strings.
  - New extension methods and advanced ranking features.
  - Richer Unicode support, and more flexible configurations.
  - Better documentation included.

## 5.0.0

- **Breaking changes:**
  - Removed conversion helpers on `Object` to prevent confusion in IDE suggestions.
  - Updated DateTime extension methods:
    - Renamed the following methods for clarity:
      - `addOrRemoveYears` to `addOrSubtractYears`
      - `addOrRemoveMonths` to `addOrSubtractMonths`
      - `addOrRemoveDays` to `addOrSubtractDays`
      - `addOrRemoveMinutes` to `addOrSubtractMinutes`
      - `addOrRemoveSeconds` to `addOrSubtractSeconds`
    - Fixed a bug in `addOrSubtractMonths` to correctly handle negative month adjustments (previously, subtracting months could result in incorrect years).
    - Improved `addOrSubtractYears` and `addOrSubtractMonths` to preserve millisecond and microsecond components (previously, these were reset to zero).

- **New features:**
  - Added new methods to DateTime:
    - `addOrSubtractMilliseconds`
    - `addOrSubtractMicroseconds`
    - `addMinutes`
    - `addSeconds`
    - `addMilliseconds`
    - `addMicroseconds`
    - `subtractDays`
    - `subtractHours`
    - `subtractMinutes`
    - `subtractSeconds`
    - `subtractMilliseconds`
    - `subtractMicroseconds`
  - Add AI documentation to the source code, enabling AI to use these utilities when crafting snippets.

## 4.1.2

- Updated docs

## 4.1.1

- Fixed `rebuild` method in the `Uri` extension to pass either path or pathSegments not both.

## 4.1.0

- Introduced `rebuild` in Uri extension, a builder-based URI replacement.

## 4.0.1

- renamed `Builder` class to `StringSimilarityBuilder` to avoid conflict with `Builder` widget the flutter sdk.

## 4.0.0

### String Similarity

- **New `StringSimilarity` Utility:** Added with algorithms like `diceCoefficient`, `levenshteinDistance`, `jaro`,
  `jaroWinkler`, and `cosine`.
- **`String` Extension:**  `compareWith` method for quick similarity comparisons.

### Debouncer

Added new `Debouncer` class for function execution control:

- Configurable delay and max wait times
- Support for sync/async functions
- Real-time state monitoring via stream
- Optional execution history tracking
- Error handling with customizable callbacks
- Debug logging capabilities
- Methods: run(), flush(), cancel(), runIfNotPending()
- State inspection: remainingTime, executionCount, etc.

### Math

- **`sqrt()`:** Added to numeric extensions for square root calculations.

### Number Extensions

- **HTTP Status Code Helpers:**
    - Added `isOkCode`, `isCreatedCode`, `isAcceptedCode`, `isNoContentCode`, `isTemporaryRedirect`,
      `isPermanentRedirect`, `isAuthenticationError`, `isValidationError`, `isRateLimitError`, `isTimeoutError`,
      `isConflictError`, `isNotFoundError`, and `isRetryableError`.
    - Added `statusCodeRetryDelay` for suggested retry durations.
    - Added `toHttpStatusUserMessage` and `toHttpStatusDevMessage` for user-friendly and developer-specific messages.
    - `isSuccessCode` now checks for all 2xx codes (not just 200 and 201).

### Delay Extensions

- **Refactored for Consistency:**
    - Removed generic `delay()` on numbers. Use specific duration methods instead (e.g., `1.secondsDelay()`,
      `5.minutesDelay()`).
    - All delay methods now support typed computations.
    - Converted getter delays to methods and used more descriptive names.

### DateTime Extensions

- Added `isBetween` for date range checks.

### Pagination

- **Unified Paginator:**  
  Introduced `BasePaginator<T>` to centralize shared logic—such as debouncing, lifecycle events, and disposal
  checks—across all paginators. The new design includes a single `InfinitePaginator` that supports both page-based and
  cursor-based infinite scrolling via dedicated factory constructors.
- **Improved AsyncPaginator:**  
  Updated `AsyncPaginator` to utilize `CancelableOperation` for deduplication and optional cancellation of in-flight
  requests when `autoCancelFetches` is set to true in `PaginationConfig`. This prevents race conditions and overlapping
  requests.
- **Enhanced Caching and Transformations:**  
  Implemented a consistent `_CacheEntry` class to cache both `Paginator<T>` objects and raw `List<T>` results with
  time-based expiration checks. Transformation methods (e.g., `where()`, `sort()`, and `map()`) now return fully
  instantiated `Paginator<T>` objects with internal caching.
- **Lifecycle and Disposal Improvements:**  
  Added robust disposal checks and modified methods (like `goToPage`) to be no-ops after disposal instead of throwing
  exceptions. This ensures that lifecycle streams remain silent post-disposal.
- **Analytics:**  
  Introduced the `PaginationAnalytics` mixin to track page loads, errors, and cache hits, enabling detailed insights
  into paginator usage.

### New Raw Data

- **HTTP Status Messages:** Added `httpStatusUserMessage` (user-friendly) and `httpStatusDevMessage` (technical) for
  explanations and troubleshooting hints.
- **cssColorNamesToArgb**: Maps CSS color names to their corresponding ARGB values. e.g. `cssColorNamesToArgb['red']`
  returns `0xFFFF0000`.

### Migration

- See the [Migration Guide](https://github.com/omar-hanafy/dart_helper_utils/tree/main/migration_guides.md) for
  upgrading instructions.

## [3.3.0]

- Introduced a new `Object` extension for converting objects into all supported types provided by the `ConvertObject`
  class.

## [3.2.0]

- Introduced `formatAsReadableNumber` on `num` for customizable number formatting.
    - Supports locale-based formatting.
    - Allows custom grouping and decimal separators.
    - Includes options for trimming trailing zeros and setting decimal precision.

- Fixed `toFullDayName` on num.

## [3.1.1]

- Fixed a bug in the `num` extension's `safeDivide` function where optional parameters were not being passed to the
  `NumbersHelper`'s method.

## [3.1.0]

Added `nullIfBlank` getter in the String Extension:

- Returns the string itself if it is not blank (non-empty and contains non-whitespace characters)
  "Hello".nullIfBlank; // Output: "Hello"
  "   ".nullIfBlank; // Output: null

## [3.0.0]

### Added

- **New Pagination Classes**:
    - `Paginator`: For synchronous pagination.
    - `AsyncPaginator`: Supports asynchronous pagination.
    - `InfinitePaginator`: Enables infinite scrolling pagination.

- **New Constants**:
    - **Greek Number Suffixes**:
        - `greekNumberSuffixes`: Suffixes for large numbers, such as `K`, `M`, `B`, representing thousands, millions,
          billions, etc.
    - **Roman Numerals**:
        - `romanNumerals`: Maps integers to Roman numerals, including `I`, `V`, `X`, `L`, `C`, `D`, `M`.
    - **Weekdays**:
        - `smallWeekdays` and `fullWeekdays`: Maps integers to abbreviated (`Mon`, `Tue`, etc.) and full weekday names (
          `Monday`, `Tuesday`, etc.).
    - **Months**:
        - `smallMonthsNames` and `fullMonthsNames`: Maps integers to abbreviated (`Jan`, `Feb`, etc.) and full month
          names (`January`, `February`, etc.).
    - **Time Durations**:
        - `oneSecond`, `oneMinute`, `oneHour`, `oneDay`: Constants for handling standard time durations.
    - **Milliseconds Constants for precise time calculations**:
        - `millisecondsPerSecond`, `millisecondsPerMinute`, `millisecondsPerHour`, `millisecondsPerDay`.
    - **Regular Expressions**:
        - Patterns for alphanumeric validation, special characters, usernames, currency, phone numbers, emails, IPv4,
          IPv6, URLs, and numeric/alphabet-only entries.
    - **HTTP Status Messages**:
        - `httpStatusMessages`: A map of HTTP status codes to their corresponding messages, from `100` (Continue) to
          `599` (Network Connect Timeout Error).

- **New DateTime Extension Method**:
    - `calculateAge()`: Calculates age from a date, with leap year consideration.

- **New Numerical Utilities**:
    - **Number Checks and Conversions**:
        - `safeDivide`: Safely divides two numbers with custom handling for division by zero.
        - `roundToNearestMultiple`, `roundUpToMultiple`, `roundDownToMultiple`: Rounds numbers to specified multiples.
        - `isBetween`: Checks if a number is within a specified range.
        - `toCurrency`, `toPercent`, `toFractionString`: Converts numbers to currency, percentage, or fraction formats.
        - `isApproximatelyEqual`, `isCloseTo`: Compares numbers with tolerance.
        - `scaleBetween`: Normalizes a number between specified minimum and maximum values.
        - `isInteger`: Checks if a number is an integer.
        - `factorial`, `gcd`, `lcm`: Calculates factorial, greatest common divisor, and least common multiple.
        - `isPrime`, `primeFactors`: Checks for primality and calculates prime factors.
        - `toRomanNumeral`, `toOrdinal`: Converts integers to Roman numerals or ordinal representation.
        - `isPerfectSquare`, `isPerfectCube`, `isFibonacci`: Checks if a number is a perfect square, cube, or Fibonacci
          number.
        - `isPowerOf`: Checks if a number is a power of another number.
        - `toBinaryString`, `toHexString`, `bitCount`: Converts integers to binary, hexadecimal, and counts set bits.
        - `isDivisibleBy`: Checks if an integer is divisible by another number.
    - **New `NumbersHelper` Class**:
        - Provides static utilities for safe division, mean, median, mode, variance, standard deviation, and
          percentiles.
        - Includes methods for GCD, perfect square checks, and Roman numeral to integer conversion.

### Changed

- **Enhanced `tryGetX` Methods** in `Iterable` and `Map` extensions to allow alternative key lookups using `altKeys` in
  methods like `getString()`, `getInt()`, etc.

### Removed (Breaking Change)

- **`HttpResStatus` Enum**:
    - Removed `HttpResStatus` enum and associated extensions, replaced by lightweight HTTP status code handling with
      methods like `toHttpStatusMessage`.

## [2.7.0]

- **Added the `toDecimalString` method on numbers**:
  similar to `toStringAsFixed` which allows formatting numbers to a specified
  number of decimal places, but this one includes optional control over trailing zeros.

## [2.6.0]

- The following methods in the DoublyLinkedList class now accept an optional `orElse`function to handle cases where no
  matching node is found:
    - `firstNodeWhere`, `lastNodeWhere`, and `singleNodeWhere`
    - `firstNodeWhereOrNull`, `lastNodeWhereOrNull`, and `singleNodeWhereOrNull`
    - `findNodeByElement`

## [2.5.3]

- `remainingDays` now returns negative values for dates in the past to correctly reflect the number of days remaining.
- `passedDays` now returns 0 for dates in the future, to correctly indicate that no days have passed yet.
- **Note:** For the previous behavior of always returning absolute day differences, use the `daysDifferenceTo` method.

## [2.5.2]

- Added support for WASM.
- Added topics to pubspec.yaml.

## [2.5.1]

- Renamed `castTo<R>()` to `convertTo<R>()` in List and Set extensions.
- Renamed `toListCasted<R>()` & `toSetCasted<R>()` to `toListConverted<R>()` & `toSetConverted<R>()` in the Iterable
  extension.
    - Reason: The methods perform type conversion rather than casting, which is more accurately reflected in the new
      names.

## [2.5.0]

- Added `castTo<R>()` to the List and Set extensions and `toListCasted<R>()` & `toSetCasted<R>()` to the Iterable
  extension.
- Enhanced numeric extensions with additional date-related helpers:
    - Added helpers to check if the number matches the current year, month, day of the month, or day of the week:
      `isCurrentYear`, `isCurrentMonth`, `isCurrentDay`, and `isCurrentDayOfWeek`.
    - `isBetweenMonths`: Checks if a number (representing a month) falls within a specified range, handling year
      boundaries gracefully.
- Added `isInThisMonth` in the date extension, it checks if a month of this date matches the month of now.
- Updated some docs.

```dart
void main() {
  final list = [1, 2, '3', '3.1', 22.3];

  // Parsing a dynamic numeric list to num, int, and double.
  print(list.castTo<num>()); // [1, 2, 3, 3.1, 22.3]
  print(list.castTo<int>()); // [1, 2, 3, 3, 22]
  print(list.castTo<double>()); // [1.0, 2.0, 3.0, 3.1, 22.3]
}
```

## [2.4.0]

### New Features

**`total` on `Iterable<num>`:** This getter computes the sum of all numeric elements within the iterable, with null
values being treated as zeros

**`totalBy` on `Iterable<E>`:** Allows you to calculate the total of a specific numeric property within the objects of
the iterable by providing a selector function.

**`nodesWhere` on `DoublyLinkedList`** The `DoublyLinkedList` now includes a `nodesWhere` method, which returns all
nodes that satisfy a given condition specified by the test function `bool Function(Node<E>)`.

```dart

num totalPrice = productList.totalBy((product) => product?.price);
int total = [1, 2, 3].total; // 6
```

## [2.3.0]

- Added `firstNodeWhere`, `firstNodeWhereOrNull`, `lastNodeWhere`, `lastNodeWhereOrNull`, `singleNodeWhere`,
  `singleNodeWhereOrNull`, `replaceNode`, `removeNodesWhere`, `swapNodes`, and `reverse`
  to the `DoublyLinkedList` class.

## [2.2.1]

- Introduced `DoublyLinkedList` a doubly linked list implementation for dart.
    - Supports standard list operations (append, prepend, insert, remove, etc.)
    - Includes convenient constructors (`filled`, `generate`, `from`)
    - Offers bidirectional traversal with `next` and `prev` node references
    - Provides `nodes` iterable for easy access to nodes in for-loops
    - Fully compatible with standard Dart `for...in` loops and other collection methods

## [2.1.0]

- Added `tryDecode` on any `String` which tries decodes the JSON string into a dynamic data structure, similar to the
  `'jsonData'.decode()` but this returns null upon failure.
- Enhanced all the `ConvertObject` methods.
- **`distinctBy` on Iterable<E>**: Resolved an issue where the `distinctBy` method did not correctly identify distinct
  elements. The method now accepts a `keySelector` function for more flexible uniqueness determination.
  ```dart
  final people = [
    Person('Alice', 25),
    Person('Bob', 30),
    Person('Alice', 28), // Duplicate name
  ];
  
  final uniquePeople = people.distinctBy((p) => p.name);
  // Result: [Person('Alice', 25), Person('Bob', 30)]
  ```

## [2.0.0]

This major release focuses on significantly enhancing internationalization (i18n) capabilities, expanding utility
functions for maps and numbers, refining date/time manipulation, and introducing substantial improvements to type
conversions.

### **Internationalization (i18n)**

#### `intl` Package Integration:

- **Extensions:**
    - **General:**
        - `intlSelectLogic`, `intlSelect` (Map)
        - `pluralize`, `getPluralCategory` (Num)
        - `setAsDefaultLocale`, `setAsSystemLocale`, `translate`, `genderSelect`, `getGenderCategory` (String)
    - **DateFormat:**
        - `tryFormat`, `format`, and various formatting methods (DateTime)
        - `dateFormat`, `toDateAutoFormat`, `toDateFormatted`, `toDateFormattedLoose`, `toDateFormattedStrict`,
          `toDateFormattedUtc`, `localeExists` (String)
    - **Bidi:**
        - `toBidiFormatter` (TextDirection)
        - Various bidi text manipulation methods (String)
    - **NumberFormat:**
        - `toNumFormatted`, `toIntFormatted`, `toDoubleFormatted` (String)
        - `formatAsCurrency`, `formatAsCompact`, and various other formatting methods (Num)
- **Access:**
    - We provided direct access to the intl common classes like `Intl`, `Bidi`, `BidiFormatter`, `NumberFormat`, and
      `DateFormat`.
    - Instead of directly exposing the `TextDirection` class (which could cause confusion with the `TextDirection` enum
      in Flutter's `dart:ui` library), we've provided three global constants:
        - `textDirectionLTR`, `textDirectionRTL`, and `textDirectionUNKNOWN`.

### **Date and Time Utilities**

#### New Getter

- `httpDateFormat` (formats this date according to [RFC-1123](https://tools.ietf.org/html/rfc1123 "RFC-1123") e.g.
  `"Thu, 1 Jan 2024 00:00:00 GMT"`)

#### Flexible Weekday Customization:

- Added optional `startOfWeek` parameter to `firstDayOfWeek` and `lastDayOfWeek`.

#### Streamlined DateTime Calculations:

- Consolidated various DateTime manipulation methods for consistency and added tests.

### **Other Utilities**

#### New Methods on Map:

- `isEqual`: checks for deep equality with other Map of the same type.
- `isPrimitive`: checks if every Key and Value is a [primitive type](https://dart.dev/language/built-in-types).
- `setIfMissing` (add entries conditionally)
- `update` (update values based on a condition)
- `filter` (filter entries using predicates)
- `keysList`, `valuesList`, `keysSet`, `valuesSet` (get lists or sets of keys/values)

#### New Methods on Iterable:

- `isEqual`: checks for deep equality with other iterable of the same type.
- `isPrimitive`: checks if every element is a [primitive type](https://dart.dev/language/built-in-types).

#### New Global Methods:

- `isEqual(dynamic a, dynamic b)`: Determines deep equality between two objects, including nested lists, maps,and custom
  types.
- `isValuePrimitive(dynamic value)`: Checks if a given value is
  a [primitive type](https://dart.dev/language/built-in-types) (e.g., `num`, `bool`, `String`,`DateTime`, etc.) based on
  its runtime type.
- `isTypePrimitive<T>()`: Checks if a given type `T` is considered a primitive type at compile time.

#### New Extractions on Map & Iterable:

- Added a new set of type-safe converters to safely extract values from `Map<K, V>` and `List<E>`:
    - `getString`, `getNum`, `getInt`, `getBigInt`, `getDouble`, `getBool`, `getDateTime`,`getUri`, `getMap`, `getSet`,
      `getList`.
    - It also supports nullable converters such as  `tryGetString`, `tryGetNum`, `tryGetInt`, etc.
    - for Map, it requires the key e.g. `map.getNum('key')`
    - for List, it requires the index e.g. `list.getNum(1)`
    - all other optionals in the `ConvertObject` class are also supported.

### **Conversion Functions**

#### Enhanced Flexibility:

- Added optional `format` and `locale` parameters to numeric conversion functions (`toNum`, `tryToNum`, `toInt`,
  `tryToInt`, `toDouble`, `tryToDouble`).
- Added optional `format`, `locale`, `autoDetectFormat`, `useCurrentLocale`, and `utc` parameters to datetime conversion
  functions (`toDateTime`, `tryToDateTime`).
- All of these optionals are available to all static methods int he ConvertObject class, as well the global methods and
  the new extraction methods on the Map and Iterable.

### **Additional Improvements**

- Fixed various minor bugs and inconsistencies in extension methods.
- Enhanced documentation.
- Added test coverage for all date related extensions, with more tests planned for the future.

### **Breaking Changes**

#### `try/toDateWithFormat` renamed to `try/toDateFormatted`:

- Update any code referencing `try/toDateWithFormat` to use `try/toDateFormatted` instead.

#### `dateFormat` on String is no longer a getter, it's a method that accepts optional `locale`:

- instead of `'yyyy MM'.dateFormat` use `'yyyy MM'.dateFormat()` or `yyyy MM'.dateFormat('en_US')`.

#### `isPrimitiveType` (Global) renamed to `isValuePrimitive`:

- Update any code referencing `isPrimitiveType` to use `isValuePrimitive` instead.

#### `flatJson` (Map) renamed to `flatMap`:

- Update any code referencing `flatJson` to use `flatMap` instead.

#### `makeEncodable` and `safelyEncodedJson` renamed to `encodableCopy` and `encodedJsonString`:

- Fixed an issue where sets were not correctly converted to JSON-encodable lists.
- Update any code referencing these methods to use their new names.

#### `firstDayOfWeek` and `lastDayOfWeek`:

- These methods now have an optional `startOfWeek` parameter, which may affect behavior if not explicitly specified.

### **Migration Guide**

- You can see the migration guide for this version
  from [here](https://github.com/omar-hanafy/dart_helper_utils/blob/main/migration_guides/mg_2.0.0.md).
- You can see all the migration guides in the GitHub repo
  from [here](https://github.com/omar-hanafy/dart_helper_utils/tree/main/migration_guides.md).

## [1.2.0]

- **New Feature:** Added the `toWords` getter on `String`, which converts any `String` to a `List<String>`, handling
  complex cases more effectively than the native `split()` method.

    - **Example Usage:**

      ```dart
      print("FlutterAndDart_are-AWESOME".toWords); // [Flutter, And, Dart, are, AWESOME]
      ```

## [1.1.0]

### Enhancements

- **String Case Conversions:**
    - `capitalizeFirstLetter`: Now **only** capitalizes the first letter, preserving the rest of the case.
    - **NEW:** `capitalizeFirstLowerRest`: Provides the previous behavior, capitalizing the first letter and lowercasing
      the rest.

### Added

- **Expanded String Case Conversions:** Added comprehensive case conversion extensions:
    - `toPascalCase`: PascalCase (UpperCamelCase).
    - `toTitleCase`: Title Case.
    - `toCamelCase`: camelCase (dromedaryCase).
    - `toSnakeCase`: snake_case (snail_case, pothole_case).
    - `toKebabCase`: kebab-case (dash-case, lisp-case, spinal-case).
    - `toScreamingSnakeCase`: SCREAMING_SNAKE_CASE (MACRO_CASE, CONSTANT_CASE, ALL_CAPS).
    - `toScreamingKebabCase`: SCREAMING-KEBAB-CASE (COBOL-CASE).
    - `toPascalSnakeCase`: Pascal_Snake_Case.
    - `toPascalKebabCase`: Pascal-Kebab-Case.
    - `toTrainCase`: Train-Case (HTTP-Header-Case).
    - `toCamelSnakeCase`: camel_Snake_Case.
    - `toCamelKebabCase`: camel-Kebab-Case.
    - `toDotCase`: dot.case.
    - `toFlatCase`: flatcase.
    - `toScreamingCase`: SCREAMINGCASE (UPPERCASE).

- **Nullable String Handling:** Added extensions for case conversion of nullable strings:
    - `lowercaseFirstLetter`: Lowercases only the first letter of the string, preserving the rest of the case.
    - `capitalizeFirstLowerRest`: Capitalizes the first letter of the string and lowers the rest.
    - `tryToLowerCase`: same as the native `toLowerCase()` but for nullable strings.
    - `tryToUpperCase` same as the native `toUpperCase()` but for nullable strings.

- **String Utility:**
    - `isBlank`: Alias for `isEmptyOrNull`, checks if a string is null, empty, or solely whitespace.

## [1.0.1]

- Updated the README.

## [1.0.0] - 2024-05-25

Initial release of [`dart_helper_utils`](https://pub.dev/packages/dart_helper_utils), which includes all the Dart
utilities from [`flutter_helper_utils`](https://pub.dev/packages/flutter_helper_utils) up to version
4.1.0

### Added

- `ConvertObject` class now accepts raw JSON strings for `List`, `Set`, and `Map` conversions, e.g.,
  `tryToList<int>("[1,2,3]")`.
- **New** `TimeUtils` class for measuring and comparing execution times, with methods like:
    - `executionDuration`: Calculates the duration of a task (synchronous or asynchronous).
    - `executionDurations`: Measures execution times for a list of tasks.
    - `compareExecutionTimes`: Compares the execution durations of two tasks.
    - `throttle`: Creates a throttled function that invokes the function at most once per specified interval.
    - `runPeriodically`: Executes a function periodically with a given interval.
    - `runWithTimeout`: Executes a function with a timeout, cancelling if it exceeds the specified duration.

### Notes

- Future updates and feature changes for Dart-specific utilities will be added to the [
  `dart_helper_utils`](https://pub.dev/packages/dart_helper_utils) package.
- If you were using Dart-specific utilities from [
  `flutter_helper_utils`](https://pub.dev/packages/flutter_helper_utils), migrate to [
  `dart_helper_utils`](https://pub.dev/packages/dart_helper_utils). If you are
  using both Flutter and Dart utilities, you can continue using [
  `flutter_helper_utils`](https://pub.dev/packages/flutter_helper_utils) as it exports [
  `dart_helper_utils`](https://pub.dev/packages/dart_helper_utils)
  internally.
- This package aims to provide comprehensive Dart utilities for non-Flutter projects.
