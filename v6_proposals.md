# v6 Proposals & Discussion

**Philosophy:** Aggressively flexible, production-grade utilities. Remove legacy/duplicate APIs, ensure symmetry, and fill gaps between the Dart SDK/Collection package and developer needs.

---

## 🚨 1. Critical Fixes (Must-Do)

Based on a deep code review of the current v6-dev branch, these issues **must** be resolved to ensure stability.

### 🐛 Bugs & Logic Errors
1.  **`takeOnly` / `drop` Runtime Error** (`iterable.dart`)
    *   **Issue:** Uses `List<E>.empty()` (fixed length) then tries to `.add()`. Will throw at runtime.
    *   **Fix:** Use `take(n).toList()` and `skip(n).toList()` or create growable lists.
2.  **`isBetween` Logic** (`date.dart`)
    *   **Issue:** `normalize`/`ignoreTime` logic creates new variables (`compareStart`) but compares them against the original `this` (or `toUtc()` result ignored).
    *   **Fix:** Ensure `this` is also normalized/stripped before comparison.
3.  **`isYesterday` / `passedDays`** (`date.dart`)
    *   **Issue:** `passedDays` returns 0 for future dates and positive for past. `isYesterday` checks `passedDays == -1`, which is impossible.
    *   **Fix:** Redefine `remainingDays`/`passedDays` to be inverses (negative/positive) or fix the boolean getters to handle the current logic correctly.
4.  **Circular Export** (`for_intl.dart`)
    *   **Issue:** `export 'for_intl.dart';` inside `for_intl.dart`.
    *   **Fix:** Remove the self-export.
5.  **`percentage` Division by Zero** (`numbers.dart`)
    *   **Issue:** `total == 0` causes crash/infinity.
    *   **Fix:** Return 0 if total is 0.
6.  **`Map.flatMap` Typing** (`map.dart`)
    *   **Issue:** Helper `flatten` expects `Map<String, dynamic>` but `this` might be `Map<String, int>`.
    *   **Fix:** Make internal helper accept `Map<dynamic, dynamic>` or explicitly cast/copy to generic map.

---

## 🛠 2. Architecture & Cleanup

### 🧹 Remove Legacy Wrappers
*   **Remove `DatesHelper`**: Pure wrapper around extensions. Encourage `date.isSameDayAs(other)`.
*   **Prune `regexValidIp6`**: The current regex is incorrect (URL-ish). Either implement real IPv6 parsing or remove.

### 🏗 Package Structure (Modularization)
*   **Proposal:** Split entry points to keep dependency graph small?
    *   `import 'package:dart_helper_utils/dart_helper_utils.dart';` (Main/Kitchen sink)
    *   `import 'package:dart_helper_utils/core.dart';` (No `intl`, `mime`, `equatable`)
    *   `import 'package:dart_helper_utils/async.dart';` (Streams, Futures, TimeUtils)

---

## 🔮 3. New Feature Proposals

Aggregated suggestions from code analysis and "pro" usage patterns.

### ⚡️ Async & Futures (Gap Filling)
*   **`Future.minWait(Duration)`**: Prevents UI flicker by ensuring a task takes at least X ms.
*   **`Future.timeoutOrNull(Duration)`**: Safe timeout that returns null instead of throwing.
*   **`Future.retry()`**: Exponential backoff retry logic for Futures (not just Streams).
*   **`TimeUtils.debounce`**: Static method returning `DebouncedCallback` (symmetry with `throttle`).
*   **`Iterable.mapConcurrent`**: Run async tasks with a parallelism limit (e.g., "download 5 files at a time").

### 🧬 Scope Functions (Kotlin-style)
*   **`let`**: (Already exists?) Verify existence in `objects.dart`.
*   **`also`**: Execute block returning original object (great for logging/setup).
*   **`takeIf` / `takeUnless`**: Filtering chains.

### 🧵 String Utilities
*   **`truncate(int length, {String suffix = '...'})`**: Proper truncation.
*   **`maskEmail` / `mask`**: Privacy helpers (e.g., `j****@gmail.com`).
*   **`words` / `lines`**: Better splitters than `split(' ')`.
*   **`toFileSize`**: `1024` -> `1 KB` (Digital storage formatting).
*   **`isUuid`**: Regex validation.

### 🧩 Collections
*   **`chunked(int size)`**: Split list into sub-lists.
*   **`partition(predicate)`**: Split into `(matches, nonMatches)`.
*   **`intersperse(element)`**: Insert separator between items (e.g., for UI dividers).
*   **`associateBy`**: List -> Map conversion.

### 📅 Date & Time
*   **`isWeekend` / `isWeekday`**: Simple getters.
*   **`roundTo` / `floorTo` / `ceilTo`**: Round dates to nearest minute/hour/day.
*   **`addBusinessDays`**: Skip weekends.

---

## 🚦 4. Decision Log

*   [ ] **Approve Critical Fixes?** (Recommended: YES)
*   [ ] **Approve Scope Functions?** (`let`, `also`, `takeIf`)
*   [ ] **Approve Async Utils?** (`minWait`, `retry`, `mapConcurrent`)
*   [ ] **Approve Collection Utils?** (`chunked`, `partition`, `intersperse`)