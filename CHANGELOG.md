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
