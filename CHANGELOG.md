### [1.0.0] - 2024-05-25

Initial release of [`dart_helper_utils`](https://pub.dev/packages/dart_helper_utils), which includes all the Dart utilities from [`flutter_helper_utils`](https://pub.dev/packages/flutter_helper_utils) up to version
4.1.0

#### Added

- `ConvertObject` class now accepts raw JSON strings for `List`, `Set`, and `Map` conversions,
  e.g., `tryToList<int>("[1,2,3]")`.
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
