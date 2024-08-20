# CHANGELOG
## [2.5.1]
- Renamed `castTo<R>()` to `convertTo<R>()` in List and Set extensions.
- Renamed `toListCasted<R>()` & `toSetCasted<R>()` to `toListConverted<R>()` & `toSetConverted<R>()` in the Iterable extension.
  - Reason: The methods perform type conversion rather than casting, which is more accurately reflected in the new names.

## [2.5.0]
- Added `castTo<R>()` to the List and Set extensions and `toListCasted<R>()` & `toSetCasted<R>()` to the Iterable extension.
- Enhanced numeric extensions with additional date-related helpers:
  - Added helpers to check if the number matches the current year, month, day of the month, or day of the week: `isCurrentYear`, `isCurrentMonth`, `isCurrentDay`, and `isCurrentDayOfWeek`.
  - `isBetweenMonths`: Checks if a number (representing a month) falls within a specified range, handling year boundaries gracefully.
- Added `isInThisMonth` in the date extension, it checks if a month of this date matches the month of now.
- Updated some docs.

```dart
void main()  {
  final list = [1, 2, '3', '3.1', 22.3];
  
  // Parsing a dynamic numeric list to num, int, and double.
  print(list.castTo<num>()); // [1, 2, 3, 3.1, 22.3]
  print(list.castTo<int>()); // [1, 2, 3, 3, 22]
  print(list.castTo<double>()); // [1.0, 2.0, 3.0, 3.1, 22.3]
}
```
## [2.4.0]
### New Features
**`total` on `Iterable<num>`:** This getter computes the sum of all numeric elements within the iterable, with null values being treated as zeros

**`totalBy` on `Iterable<E>`:** Allows you to calculate the total of a specific numeric property within the objects of the iterable by providing a selector function.

**`nodesWhere` on `DoublyLinkedList`** The `DoublyLinkedList` now includes a `nodesWhere` method, which returns all nodes that satisfy a given condition specified by the test function `bool Function(Node<E>)`.

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
- Added `tryDecode` on any `String` which tries decodes the JSON string into a dynamic data structure, similar to the `'jsonData'.decode()` but this returns null upon failure.
- Enhanced all the `ConvertObject` methods.
- **`distinctBy` on Iterable<E>**: Resolved an issue where the `distinctBy` method did not correctly identify distinct elements. The method now accepts a `keySelector` function for more flexible uniqueness determination.
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

This major release focuses on significantly enhancing internationalization (i18n) capabilities, expanding utility functions for maps and numbers, refining date/time manipulation, and introducing substantial improvements to type conversions.

### **Internationalization (i18n)**
#### `intl` Package Integration:
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
  - **Access:**
    - We provided direct access to the intl common classes like `Intl`, `Bidi`, `BidiFormatter`, `NumberFormat`, and `DateFormat`.
    - Instead of directly exposing the `TextDirection` class (which could cause confusion with the `TextDirection` enum in Flutter's `dart:ui` library), we've provided three global constants:
      - `textDirectionLTR`, `textDirectionRTL`, and `textDirectionUNKNOWN`.

### **Date and Time Utilities**
#### New Getter
  - `httpFormat` (formats this date according to [RFC-1123](https://tools.ietf.org/html/rfc1123 "RFC-1123") e.g. `"Thu, 1 Jan 2024 00:00:00 GMT"`)
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
- `isEqual(dynamic a, dynamic b)`: Determines deep equality between two objects, including nested lists, maps,and custom types.
- `isValuePrimitive(dynamic value)`: Checks if a given value is a [primitive type](https://dart.dev/language/built-in-types) (e.g., `num`, `bool`, `String`,`DateTime`, etc.) based on its runtime type.
- `isTypePrimitive<T>()`: Checks if a given type `T` is considered a primitive type at compile time.

#### New Extractions on Map & Iterable:
  - Added a new set of type-safe converters to safely extract values from `Map<K, V>` and `List<E>`:
    -  `getString`, `getNum`, `getInt`, `getBigInt`, `getDouble`, `getBool`, `getDateTime`,`getUri`, `getMap`, `getSet`, `getList`.
    - It also supports nullable converters such as  `tryGetString`, `tryGetNum`, `tryGetInt`, etc.
    - for Map, it requires the key e.g. `map.getNum('key')`
    - for List, it requires the index e.g. `list.getNum(1)`
    - all other optionals in the `ConvertObject` class are also supported.

### **Conversion Functions**
#### Enhanced Flexibility:
  - Added optional `format` and `locale` parameters to numeric conversion functions (`toNum`, `tryToNum`, `toInt`, `tryToInt`, `toDouble`, `tryToDouble`).
  - Added optional `format`, `locale`, `autoDetectFormat`, `useCurrentLocale`, and `utc` parameters to datetime conversion functions (`toDateTime`, `tryToDateTime`).
  - All of these optionals are available to all static methods int he ConvertObject class, as well the global methods and the new extraction methods on the Map and Iterable.

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
- You can see the migration guide for this version from [here](https://github.com/omar-hanafy/dart_helper_utils/blob/main/migration_guides/mg_2.0.0.md).
- You can see all the migration guides in the GitHub repo from [here](https://github.com/omar-hanafy/dart_helper_utils/tree/main/migration_guides). 

## [1.2.0]
- **New Feature:** Added the `toWords` getter on `String`, which converts any `String` to a `List<String>`, handling complex cases more effectively than the native `split()` method.
  
  - **Example Usage:**
    
    ```dart
    print("FlutterAndDart_are-AWESOME".toWords); // [Flutter, And, Dart, are, AWESOME]
    ```

## [1.1.0]
### Enhancements
- **String Case Conversions:**
  - `capitalizeFirstLetter`: Now **only** capitalizes the first letter, preserving the rest of the case.
  - **NEW:** `capitalizeFirstLowerRest`: Provides the previous behavior, capitalizing the first letter and lowercasing the rest.

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
Initial release of [`dart_helper_utils`](https://pub.dev/packages/dart_helper_utils), which includes all the Dart utilities from [`flutter_helper_utils`](https://pub.dev/packages/flutter_helper_utils) up to version
4.1.0

### Added

- `ConvertObject` class now accepts raw JSON strings for `List`, `Set`, and `Map` conversions, e.g., `tryToList<int>("[1,2,3]")`.
- **New** `TimeUtils` class for measuring and comparing execution times, with methods like:
    - `executionDuration`: Calculates the duration of a task (synchronous or asynchronous).
    - `executionDurations`: Measures execution times for a list of tasks.
    - `compareExecutionTimes`: Compares the execution durations of two tasks.
    - `throttle`: Creates a throttled function that invokes the function at most once per specified interval.
    - `runPeriodically`: Executes a function periodically with a given interval.
    - `runWithTimeout`: Executes a function with a timeout, cancelling if it exceeds the specified duration.

### Notes

- Future updates and feature changes for Dart-specific utilities will be added to the [`dart_helper_utils`](https://pub.dev/packages/dart_helper_utils) package.
- If you were using Dart-specific utilities from [`flutter_helper_utils`](https://pub.dev/packages/flutter_helper_utils), migrate to [`dart_helper_utils`](https://pub.dev/packages/dart_helper_utils). If you are
  using both Flutter and Dart utilities, you can continue using [`flutter_helper_utils`](https://pub.dev/packages/flutter_helper_utils) as it exports [`dart_helper_utils`](https://pub.dev/packages/dart_helper_utils)
  internally.
- This package aims to provide comprehensive Dart utilities for non-Flutter projects.
