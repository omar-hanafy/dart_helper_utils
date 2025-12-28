[![dart_helper_utils logo](https://raw.githubusercontent.com/omar-hanafy/dart_helper_utils/fb2b340acff23ad89b09319dac691d98f1ecca90/logo.svg)](https://pub.dev/packages/dart_helper_utils)

[![pub package](https://img.shields.io/pub/v/dart_helper_utils)](https://pub.dev/packages/dart_helper_utils)

**`dart_helper_utils`** is a toolkit designed to make coding in Dart more convenient by offering utilities for type conversions, data manipulation, time measurements, HTTP status handling, and much more. We’ve bundled a wide range of extension methods and helper classes that let you write less code and focus on your app's core logic.

> **Note:** If you’re working on a Flutter project, we recommend using [`flutter_helper_utils`](https://pub.dev/packages/flutter_helper_utils). It includes everything you’ll find here, plus Flutter-specific extensions like widgets and color utilities.

---

## Why Use dart_helper_utils?

We initially created `dart_helper_utils` to gather all those tiny, repetitive tasks that pop up in Dart projects—think date parsing, JSON decoding, or string manipulation. Over time, we introduced more powerful features like advanced string transformations, numeric calculations, and user-friendly HTTP status messages. The result is a collection of robust, well-tested utilities that you can easily slot into your own Dart applications.

### 1. Parsing Dynamic JSON Data

**Before** (typical Dart approach):
```dart
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name']?.toString() ?? 'Unknown',
      age: int.tryParse(json['age']?.toString() ?? '') ?? 0,
      scores: (json['scores'] as List?)
              ?.map((e) => double.parse(e.toString()))
              .toList() ?? [],
    );
  }
```

**After**:
```dart
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json.getString('name', defaultValue: 'Unknown'),
      age: json.getInt('age'),
      scores: json.getList<double>('scores'),
    );
  }
```
---

### 2. Date Handling

**Before**:
```dart
bool isDateValid(DateTime? date) {
  if (date == null) return false;
  final now = DateTime.now();
  return date.year == now.year && 
         date.month == now.month && 
         date.day == now.day;
}
```

**After**:
```dart
bool isDateValid(DateTime? date) {
  return date?.isToday ?? false;
}
```

---

### 3. Duration Delays

**Before**:
```dart
await Future<void>.delayed(const Duration(seconds: 3));
```

**After**:
```dart
await 3.secondsDelay();
```

---

### 4. HTTP Status Handling

**Before**:

```dart
String getErrorMessage(int statusCode) {
  switch (statusCode) {
    case 429:
      return 'Too many requests. Please wait before trying again.';
    case 404:
      return 'Resource not found. Please check the URL.';
    case 500:
      return 'Server error. Please try again later.';
    default:
      return 'An error occurred.';
  }
}
```

**After**:
```dart
String getErrorMessage(int statusCode) {
  return statusCode.toHttpStatusUserMessage;
}
```

---

### 5. Collection Transformations

**Before**

```dart
List<String> processItems(List<dynamic>? items) {
  if (items == null) return [];
  
  final result = <String>[];
  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    if (item != null) {
      result.add(item.toString());
    }
  }
  return result;
}
```

**After**:

```dart
final processed = items?.convertTo<String>() ?? [];
```

---

## Getting Started

### Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  dart_helper_utils: ^6.0.0-dev.2
```

Then run:
```bash
dart pub get   # For Dart projects
# or
flutter pub get # For Flutter projects
```

### Basic Usage

Import the package:

```dart
import 'package:dart_helper_utils/dart_helper_utils.dart';
```

Start using the extensions and utilities:

```dart
// String operations
final text = "hello_world_example";
print(text.toCamelCase);  // "helloWorldExample"

// Safe number conversion
final value = "123.45".tryToDouble() ?? 0.0;

// Date handling
final date = DateTime.now();
print(date.isToday);  // true
print(date.format("dd/MM/yyyy"));  // "16/01/2025"

// Collection utilities
final list = [1, 2, null, 3, null, 4];
print(list.whereNotNull());  // [1, 2, 3, 4]
```
---

## Core Features
### String Similarity & Text Operations

Powerful text manipulation tools including case conversion and similarity checks:

```dart
// Case conversions
final text = "helloWorld_example-TEXT";
print(text.toPascalCase);           // HelloWorldExampleText
print(text.toSnakeCase);            // hello_world_example_text
print(text.toKebabCase);            // hello-world-example-text
print(text.toScreamingSnakeCase);   // HELLO_WORLD_EXAMPLE_TEXT

// String similarity checks
final str1 = "hello";
final str2 = "hallo";

// Different algorithms available
final similarity = str1.compareWith(
  str2, 
  algorithm: StringSimilarityAlgorithm.levenshtein
);
print(similarity); // 0.8

// Words extraction (smarter than simple split)
print("FlutterAndDart_are-AWESOME".toWords);
// [Flutter, And, Dart, are, AWESOME]
```
---

### Type-Safe Conversions

Safe extraction and conversion of values from dynamic data:

```dart
// Safe JSON parsing
final jsonStr = '{"name":"John","age":"25","scores":[90,85,95]}';
final map = jsonStr.decode();

// Type-safe extractions
final name = map.getString('name');      // "John"
final age = map.getInt('age');           // 25
final scores = map.getList<int>('scores');  // [90, 85, 95]

// Nested extractions
final userData = {
  'user': {
    'details': {
      'address': {'zipcode': '12345'}
    }
  }
};

// Safe nested access with fallback
final zipcode = userData.getInt(
  'user', 
  innerKey: 'details.address.zipcode',
  defaultValue: 0
); // 12345

// Complex conversions
final date = "2024-01-16".toDateTime(format: "yyyy-MM-dd");
final number = "1,234.56".toNum(format: "#,##0.00");
```
---

### Debouncer

Utility for managing rapid event sequences by delaying action execution until after a quiet period. Perfect for search inputs, form validation, API calls, and other scenarios where you want to limit the frequency of operations.

```dart
// Create a debouncer with 300ms delay
final debouncer = Debouncer(delay: Duration(milliseconds: 300));

// Use in a search field
TextField(
  onChanged: (value) {
    debouncer.run(() async {
      // This will only execute 300ms after the last keystroke
      await searchApi(value);
    });
  },
)

// Don't forget to dispose
@override
void dispose() {
  debouncer.dispose();
  super.dispose();
}
```

---

### Time & Execution Utils

Comprehensive utilities for measuring and controlling execution time:

```dart
// Measure execution duration
final duration = await TimeUtils.executionDuration(() async {
  await someExpensiveOperation();
});
print("Operation took ${duration.inMilliseconds}ms");

// Run with timeout
try {
  final result = await TimeUtils.runWithTimeout(
    task: () => longRunningTask(),
    timeout: Duration(seconds: 5),
  );
} catch (e) {
  print('Task timed out');
}

// Throttle function calls
final throttled = TimeUtils.throttle(
  () => print('Throttled function called'),
  Duration(seconds: 1),
  trailing: true,
);
throttled();

// Run periodic tasks
final timer = TimeUtils.runPeriodically(
  interval: Duration(minutes: 1),
  onExecute: (timer, count) => checkForUpdates(),
);

// Clean up when done
timer.cancel();
```

---

## Extensions Deep Dive

### Date & Time Extensions

Simplify date operations and comparisons:

```dart
final date = DateTime.now();

// Quick comparisons
print(date.isToday);         // true
print(date.isTomorrow);      // false
print(date.isYesterday);     // false
print(date.isWeekend);       // depends on the date

// Navigation
final nextWeek = date.nextWeek;
final prevMonth = date.previousMonth;
final startOfDay = date.startOfDay;
final endOfMonth = date.endOfMonth;

// Duration calculations
final otherDate = DateTime(2025, 12, 31);
print(date.remainingDays(otherDate));    // days until otherDate
print(date.passedDays(otherDate));       // days since otherDate

// Formatting
print(date.format('dd/MM/yyyy'));        // "16/01/2025"
print(date.httpDateFormat);              // "Thu, 16 Jan 2025 00:00:00 GMT"

// Age calculation
final birthDate = DateTime(1990, 1, 1);
print(birthDate.calculateAge());         // 35 (as of 2025)
```

---

### Collections Extensions

Powerful extensions for Lists, Maps, and Sets:

```dart
// List Extensions
final list = [1, 2, null, 3, null, 4];
print(list.whereNotNull());              // [1, 2, 3, 4]
print(list.firstOrDefault(0));           // 1
print(list.distinctBy((e) => e));        // [1, 2, null, 3, 4]

// Splitting lists
print(list.firstHalf);                   // [1, 2, null]
print(list.secondHalf);                  // [3, null, 4]

// Map Extensions
final map = {'name': 'John', 'scores': [85, 90, 95]};

// Safe extractions with defaults
final name = map.getString('name', defaultValue: 'Unknown');
final scores = map.getList<int>('scores', defaultValue: []);

// Manipulation
map.setIfMissing('email', 'default@email.com');
final filtered = map.filter((key, value) => value != null);

// Set Extensions
final set = {1, 2, 3};
set.addIfNotNull(4);                     // Adds only if not null
set.removeWhere((e) => e.isEven);        // Removes even numbers

// Common Iterable Extensions
final items = [1, 2, 3, 4, 5];
print(items.total);                      // Sum: 15
print(items.tryGetRandom());             // Random element or null
```
---

### Numbers & Math Extensions

Enhanced numeric operations and conversions:

```dart
// Basic Operations
final num = 123.456;
print(num.roundToNearest(5));           // 125
print(num.isBetween(100, 200));         // true

// Numeric Checks
print(42.isPrime);                      // false
print(16.isPerfectSquare);              // true
print(8.isPerfectCube);                 // true

// Currency and Formatting
final price = 1234567.89;
print(price.formatAsCurrency());        // "$1,234,567.89"
print(price.formatAsCompact());         // "1.2M"
print(price.asGreeks);                  // "1.23M"

// Time Conversions
await 5.secondsDelay();                   // Delays for 5 seconds
final duration = 30.asMinutes;            // Duration of 30 minutes

// HTTP Status Helpers
print(200.isSuccessCode);              // true
print(404.isNotFoundError);            // true
print(429.statusCodeRetryDelay);       // Suggested retry duration
```

---

### String Extensions

Rich text manipulation and validation:

```dart
// Smart Case Conversions
final text = "helloWorld_example-TEXT";
print(text.toPascalCase);             // HelloWorldExampleText
print(text.toSnakeCase);              // hello_world_example_text
print(text.toDotCase);                // hello.world.example.text

// Validation
print("test@email.com".isValidEmail);   // true
print("192.168.1.1".isValidIp4);        // true
print("https://dart.dev".isValidUrl);   // true

// Text Manipulation
print("  hello  world  ".removeWhiteSpaces());  // "helloworld"
print("hello".padCenter(10, '*'));      // "**hello***"

// Safe Operations
final nullableText = null;
print(nullableText.orEmpty);            // ""
print("".ifEmpty(() => "default"));     // "default"

// JSON Handling
final jsonStr = '{"key": "value"}';
print(jsonStr.decode());                // Map<String, dynamic>
print(jsonStr.tryDecode());             // Returns null if invalid
```
---

### HTTP Status Extensions

Clean and informative HTTP status handling:

```dart
final statusCode = 404;

// Status Checks
print(statusCode.isSuccessCode);        // false
print(statusCode.isNotFoundError);      // true
print(statusCode.isRetryableError);     // false

// User Messages
print(statusCode.toHttpStatusUserMessage);
// "The requested resource could not be found. Please check the URL and try again."

// Developer Messages
print(statusCode.toHttpStatusDevMessage);
// "Resource not found. Verify the path and parameters. Check if resource exists..."

// Retry Handling
if (statusCode.isRateLimitError) {
  final delay = statusCode.statusCodeRetryDelay;
  print("Retry after: ${delay.inSeconds} seconds");
}
```

---

## Additional Utilities

### DoublyLinkedList

`DoublyLinkedList` moved to its own package: `doubly_linked_list`.
Use it directly from `https://pub.dev/packages/doubly_linked_list`.
---

### Regular Expressions

Pre-defined RegExp patterns for common validation scenarios:

```dart
// Common patterns
print(RegExp(alphanumericPattern).hasMatch('Test123'));    // true
print(RegExp(specialCharsPattern).hasMatch('Test@123'));   // true
print(RegExp(usernamePattern).hasMatch('user_123'));       // true
print(RegExp(phoneNumberPattern).hasMatch('+1234567890')); // true

// Validation using String extensions
print("test@email.com".isValidEmail);   // true
print("192.168.1.1".isValidIp4);        // true
print("https://dart.dev".isValidUrl);   // true
print("12345".isNumeric);               // true
print("abcDEF".isAlphabet);             // true
```
---

### Constants & Formats

Built-in constants for common operations:

```dart
// Time Constants
print(oneSecond);              // Duration(seconds: 1)
print(oneMinute);              // Duration(minutes: 1)
print(oneHour);                // Duration(hours: 1)
print(oneDay);                 // Duration(days: 1)

// Milliseconds Constants
print(millisecondsPerSecond);  // 1000
print(millisecondsPerMinute);  // 60000
print(millisecondsPerHour);    // 3600000
print(millisecondsPerDay);     // 86400000

// Number Formats
print(greekNumberSuffixes);
// {
//   'K': 1000,
//   'M': 1000000,
//   'B': 1000000000,
//   'T': 1000000000000,
// }

// Calendar Constants
print(smallWeekdays);     // {1: 'Mon', 2: 'Tue', ...}
print(fullWeekdays);      // {1: 'Monday', 2: 'Tuesday', ...}
print(smallMonthsNames);  // {1: 'Jan', 2: 'Feb', ...}
print(fullMonthsNames);   // {1: 'January', 2: 'February', ...}

// Roman Numerals
print(romanNumerals);
// {1: 'I', 5: 'V', 10: 'X', 50: 'L', 100: 'C', 500: 'D', 1000: 'M'}
```
---

## Contributing

We love contributions! If you’d like to add a feature, report a bug, or suggest an improvement, open an issue or submit a pull request in the [GitHub repository](https://github.com/omar-hanafy/dart_helper_utils). We appreciate every piece of feedback and aim to make things smoother for everyone.

---

## License

`dart_helper_utils` is released under the [BSD 3-Clause License](https://opensource.org/license/bsd-3-clause/). You’re free to use, modify, and distribute it as long as you comply with the license terms.

If this package saves you time or helps you ship faster, consider buying me a coffee. It goes a long way in helping maintain and improve these tools.

<a href="https://www.buymeacoffee.com/omar.hanafy" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>

---

Thank you for choosing **`dart_helper_utils`**. We hope it makes your next Dart project more enjoyable and efficient! If you run into any issues or have suggestions, don’t hesitate to reach out.

---

**Keywords**: extension pack, helpers, utilities, string manipulation, conversions, time utils, date extension, datetime helper, DateFormat, intl, extensions, iterable, map, number, object, set, URI, boolean extension, JSON encoding/decoding, parsing, safe parsing, object conversion, cast, list casting.
