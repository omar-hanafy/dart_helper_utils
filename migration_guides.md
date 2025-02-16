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
