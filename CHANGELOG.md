# CHANGELOG
### [2.0.0]

This major release focuses on significantly enhancing internationalization (i18n) capabilities, expanding utility functions for maps and numbers, refining date/time manipulation, and introducing substantial improvements to type conversions.

#### Internationalization (i18n)
- **`intl` Package Integration:**
  - Introduced comprehensive support for localization and formatting using the `intl` package.
  - **Extensions:**
    - **General:**
      - `intlSelectLogic`, `intlSelect` (Map)
      - `pluralize`, `getPluralCategory` (Num)
      - `setAsDefaultLocale`, `setAsSystemLocale`, `translate`, `genderSelect`, `getGenderCategory` (String)
    - **DateFormat:**
      - `tryFormat`, `format`, and various formatting methods (DateTime)
      - `dateFormat`, `toDateAutoFormat`, `toDateFormatted`, `toDateFormattedLoose`, `toDateFormattedStrict`, `toDateFormattedUtc`, `localeExists` (String)
    - **Bidi:**
      - `toBidiFormatter` (TextDirection)
      - Various bidi text manipulation methods (String)
    - **NumberFormat:**
      - `toNumFormatted`, `toIntFormatted`, `toDoubleFormatted` (String)
      - `formatAsCurrency`, `formatAsCompact`, and various other formatting methods (Num)

#### Map Utilities
- **New Methods:**
  - `setIfMissing` (add entries conditionally)
  - `update` (update values based on a condition)
  - `filter` (filter entries using predicates)
  - `keysList`, `valuesList`, `keysSet`, `valuesSet` (get lists or sets of keys/values)

#### Date and Time Utilities
- **New Getters:**
  - `httpFormat` (formats this date according to [RFC-1123](http://tools.ietf.org/html/rfc1123 "RFC-1123") e.g. `"Thu, 1 Jan 2024 00:00:00 GMT"`)
- **Flexible Weekday Customization:**
  - Added optional `startOfWeek` parameter to `firstDayOfWeek` and `lastDayOfWeek`.
- **Streamlined DateTime Calculations:**
  - Consolidated various DateTime manipulation methods for consistency and added tests.

#### Conversion Functions
- **Enhanced Flexibility:**
  - Added optional `format` and `locale` parameters to numeric conversion functions (`toNum`, `tryToNum`, `toInt`, `tryToInt`, `toDouble`, `tryToDouble`).
  - Added optional `format`, `locale`, `autoDetectFormat`, `useCurrentLocale`, and `utc` parameters to datetime conversion functions (`toDateTime`, `tryToDateTime`).

#### Additional Improvements
- Fixed various minor bugs and inconsistencies in extension methods.
- Enhanced documentation for clarity and usability.
- Added test coverage for all date related extensions, with more tests planned for the future.

#### Breaking Changes 
- **`try/toDateWithFormat` renamed to `try/toDateFormatted`:**
  - Update any code referencing `try/toDateWithFormat` to use `try/toDateFormatted` instead.
  
- **`dateFormat` on String is no longer a getter, its a method that aceepts optional `locale`:**
  - instead of `'yyyy MM'.dateFormat` use `'yyyy MM'.dateFormat()` or `yyyy MM'.dateFormat('en_US')`.
  
- **`flatJson` (Map) renamed to `flatMap`:**
  - Update any code referencing `flatJson` to use `flatMap` instead.

- **`makeEncodable` and `safelyEncodedJson` renamed to `encodableCopy` and `encodedJsonString`:**
  - Fixed an issue where sets were not correctly converted to JSON-encodable lists.
  - Update any code referencing these methods to use their new names.

- **`firstDayOfWeek` and `lastDayOfWeek`:**
  - These methods now have an optional `startOfWeek` parameter, which may affect behavior if not explicitly specified.

#### Migration Guide
- You can see the migration guide for this version from [here](https://github.com/omar-hanafy/dart_helper_utils/blob/main/migration_guides/mg_2.0.0.md).
- You can see all the migration guides in the GitHub repo from [here](https://github.com/omar-hanafy/dart_helper_utils/tree/main/migration_guides). 

### [1.2.0]

- **New Feature:** Added the `toWords` getter on `String`, which converts any `String` to a `List<String>`, handling complex cases more effectively than the native `split()` method.
  
  - **Example Usage:**
    
    ```dart
    print("FlutterAndDart_are-AWESOME".toWords); // [Flutter, And, Dart, are, AWESOME]
    ```

### [1.1.0]

#### Enhancements
- **String Case Conversions:**
  - `capitalizeFirstLetter`: Now **only** capitalizes the first letter, preserving the rest of the case.
  - **NEW:** `capitalizeFirstLowerRest`: Provides the previous behavior, capitalizing the first letter and lowercasing the rest.

#### Added
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

### [1.0.1]

- Updated the README.

### [1.0.0] - 2024-05-25

Initial release of [`dart_helper_utils`](https://pub.dev/packages/dart_helper_utils), which includes all the Dart utilities from [`flutter_helper_utils`](https://pub.dev/packages/flutter_helper_utils) up to version
4.1.0

#### Added

- `ConvertObject` class now accepts raw JSON strings for `List`, `Set`, and `Map` conversions, e.g., `tryToList<int>("[1,2,3]")`.
- **New** `TimeUtils` class for measuring and comparing execution times, with methods like:
    - `executionDuration`: Calculates the duration of a task (synchronous or asynchronous).
    - `executionDurations`: Measures execution times for a list of tasks.
    - `compareExecutionTimes`: Compares the execution durations of two tasks.
    - `throttle`: Creates a throttled function that invokes the function at most once per specified interval.
    - `runPeriodically`: Executes a function periodically with a given interval.
    - `runWithTimeout`: Executes a function with a timeout, cancelling if it exceeds the specified duration.

#### Notes

- Future updates and feature changes for Dart-specific utilities will be added to the [`dart_helper_utils`](https://pub.dev/packages/dart_helper_utils) package.
- If you were using Dart-specific utilities from [`flutter_helper_utils`](https://pub.dev/packages/flutter_helper_utils), migrate to [`dart_helper_utils`](https://pub.dev/packages/dart_helper_utils). If you are
  using both Flutter and Dart utilities, you can continue using [`flutter_helper_utils`](https://pub.dev/packages/flutter_helper_utils) as it exports [`dart_helper_utils`](https://pub.dev/packages/dart_helper_utils)
  internally.
- This package aims to provide comprehensive Dart utilities for non-Flutter projects.
