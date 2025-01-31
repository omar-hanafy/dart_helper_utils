# Migration Guide (v4)

### 1. Update Imports and Class Names

- In older versions, you may have imported a single file containing `Paginator` or `AsyncPaginator`. Now, these classes
  might be organized differently, possibly split across multiple files or using new package imports.
- If you see errors referencing `IPaginator` or `BasePaginator`, ensure you've updated import paths to point to the new,
  refactored code.

### 2. Adjust for New `BasePaginator` and Lifecycle Events

- Version 4 introduces a `BasePaginator<T>` class that centralizes shared logic. If you subclassed an old `Paginator`
  directly, you'll now likely extend `BasePaginator<T>` or `Paginator<T>` instead.
- If you relied on custom page-change logic, override `onPageChanged` in your subclass. This replaces older patterns
  where you might have had your own "goToPage" hooking mechanism.

### 3. Handle Casting and Transformations

- In prior versions, transformations like `filter()` or `sorted()` might have returned raw lists or used a different
  caching approach. Now, we store and retrieve fully instantiated `Paginator<T>` objects in an internal
  `_transformCache` with time-based expiration.
- If your code was accessing transform results directly, you'll need to rely on the newly returned `Paginator<T>` from
  methods like `where(...)` or `sort(...)`.

### 4. Use `CancelableOperation` in `AsyncPaginator` (Optional)

- If you want to avoid overlapping fetch requests, ensure `autoCancelFetches` is set to `true` in your
  `PaginationConfig`. If you're upgrading and want to preserve old behavior (which might allow multiple fetches at
  once), you can set it to `false`.

### 5. Infinite Paginator Changes

- The `InfinitePaginator` now supports both page-based and cursor-based patterns through factory constructors. If you
  previously used separate classes for these patterns, you might need to switch to `InfinitePaginator.pageBased()` or
  `InfinitePaginator.cursorBased()`.
- Check your existing code for any references to legacy infinite scroll classes or direct calls that now require passing
  a `paginationKey`. Adapt them to match the new factory constructor signature.

### 6. Number Extensions Delay Methods

- The `delay()` method has been removed in favor of more specific duration-based delays.
- Replace `n.delay()` calls with the appropriate specific delay method:
  ```dart
  // Old
  await 2.delay();
  await 2.secDelay;
  await 5.minDelay;
  await 1.daysDelay;
  
  // New
  await 2.secondsDelay();
  await 5.minutesDelay();
  await 1.daysDelay();
  ```
- All delay methods now support generic return types for computations:
  ```dart
  // Old
  await 2.delay(() => someFunction());
  
  // New
  final result = await 2.secondsDelay(() => someFunction());
  ```

### 7. Analytics (Optional)

- If you want to track usage metrics, add the `PaginationAnalytics` mixin to your custom paginator class. This is
  optional but can be handy if you want to log the number of page loads, errors, etc.

### 8. Testing

- Lastly, confirm your existing tests still pass or update them to reflect any structural changes in version 4 (like new
  method names, new overrides, or changed class hierarchies).

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
