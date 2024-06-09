## Migration Guide for Dart Helper Utils 2.0.0

### 1. Date and Time Parsing

The `try/toDateWithFormat` methods have been replaced with a more versatile `try/toDateFormatted` methods.
- This new methods offers enhanced flexibility by supporting various date/time formats, locales, and time zones.
- It can autodetect popular formats if the format is not provided.
- Due to the expanded range of supported formats, some strings that previously caused errors might now be parsed successfully but with different values.
- to disable autodetect formats set the `autoDetectFormat: false` in the method signature.

New signatures are:
- String? format,
- String? locale,
- bool autoDetectFormat = true,
- bool useCurrentLocale = false,
- bool utc = false,

**Old Usage:**

```dart
String dateString = "2024-06-08";
DateTime? dateTime = dateString.tryToDateWithFormat(format: 'YYYY-MM-dd'); // or dateString.toDateTime
```

**New Usage:**

```dart
String dateString = "2024/06/08";
// you can also pass the format but it auto detects it now.
DateTime? dateTime = dateString.tryToDateFormatted(); // or dateString.toDateTime()
```

### 2. `firstDayOfWeek` and `lastDayOfWeek`

These methods now have an optional `startOfWeek` parameter to customize the first day of the week. The default value is `DateTime.monday`.

**Old Usage:**

```
DateTime now = DateTime.now();
DateTime firstDayOfWeek = now.firstDayOfWeek;
DateTime lastDayOfWeek = now.lastDayOfWeek;
```

**New Usage:**

```
DateTime now = DateTime.now();
DateTime firstDayOfWeek = now.firstDayOfWeek(); // Defaults to Monday
DateTime lastDayOfWeek = now.lastDayOfWeek(); // Defaults to Monday

// Customize start of week (e.g., Sunday)
DateTime firstDayOfWeekSunday = now.firstDayOfWeek(startOfWeek: DateTime.sunday);
```

### 3. Map Methods

- **`flatJson` renamed to `flatMap`:** If you were using the `flatJson` method on `Map<String, dynamic>`, update your code to use `flatMap` instead. The functionality has been enhanced to handle arrays, circular references, and provide an option to exclude arrays.
- **`makeEncodable` and `safelyEncodedJson` renamed:** The `makeEncodable` and `safelyEncodedJson` methods on `Map<K, V>` have been renamed to `encodableCopy` and `encodedJsonString`, respectively. Additionally, an issue where sets were not correctly converted to JSON-encodable lists has been fixed.

### 4. Other Breaking Changes

Review the [changelog](https://github.com/omar-hanafy/dart_helper_utils/blob/main/CHANGELOG.md#200) for any other minor breaking changes and update your code accordingly.

### Troubleshooting

If you encounter any issues during the migration process please fill an [issue here.](https://github.com/omar-hanafy/dart_helper_utils/issues)
