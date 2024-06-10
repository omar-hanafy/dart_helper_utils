## Migration Guide for Dart Helper Utils 2.0.0

### 1. Date and Time Parsing

- **`try/toDateWithFormat` renamed to `try/toDateFormatted`:**
    - **Action:** Update all instances of `try/toDateWithFormat` in your code to `try/toDateFormatted`.

- **`dateFormat` on String is now a method with an optional `locale` parameter:**
This change gives you more control over the formatting process, allowing you to specify the locale explicitly for accurate results.
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
These methods now have an optional `startOfWeek` parameter to customize the first day of the week. The default value is `DateTime.monday`.

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

- **`flatJson` renamed to `flatMap`:** If you were using the `flatJson` method on `Map<String, dynamic>`, update your code to use `flatMap` instead. The functionality has been enhanced to handle arrays, circular references, and provide an option to exclude arrays.
- **`makeEncodable` and `safelyEncodedJson` renamed:** The `makeEncodable` and `safelyEncodedJson` methods on `Map<K, V>` have been renamed to `encodableCopy` and `encodedJsonString`, respectively. Additionally, an issue where sets were not correctly converted to JSON-encodable lists has been fixed.

### 4. Other Breaking Changes

Review the [changelog](https://github.com/omar-hanafy/dart_helper_utils/blob/main/CHANGELOG.md#200) for any other minor breaking changes and update your code accordingly.

### Troubleshooting

If you encounter any issues during the migration process please fill an [issue here.](https://github.com/omar-hanafy/dart_helper_utils/issues)
