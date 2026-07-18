---
name: async-with-dart-helper-utils
description: Use when Dart/Flutter code needs debouncing, throttling, stream shaping, or bounded-concurrency async work with the dart_helper_utils package - search-input debounce, rate-limited event streams, Debouncer/DebouncedCallback/Throttler lifecycle and disposal, TimeUtils.debounce/throttle/runWithTimeout, stream bufferCount/window/rateLimit/asPausable/withLatestValue/retry/replaceOnError, StreamController safeAdd/safeClose, Future minWait/timeoutOrNull, retry with exponential backoff, waitConcurrency, or mapConcurrent.
---

# Async, timing, and streams with dart_helper_utils

These APIs carry lifecycle and ordering semantics that agents reliably get
wrong from memory (wrong names, wrong parameter names, missed disposal,
wrong result ordering). Use the exact contracts below.

## Choosing the right primitive

| Need | Use |
|---|---|
| Collapse a burst into one trailing call (search input) | `TimeUtils.debounce(fn, duration)` or a `Debouncer` you manage |
| At most one call per interval (scroll, resize) | `TimeUtils.throttle(fn, interval, trailing: ...)` |
| Cap a STREAM's event rate | `stream.rateLimit(maxEvents, window)` - overflow events are DROPPED, not queued |
| Batch stream events by count / by time | `bufferCount(n)` / `window(duration)` |
| Hold stream events until ready | `stream.asPausable()` |
| Late subscribers need the last value | `stream.withLatestValue()` |
| Bound how many futures run at once | `thunks.waitConcurrency(concurrency: 5)` or `items.mapConcurrent(fn, parallelism: 3)` |
| Retry a flaky async call | `(() => call()).retry(retries: 3)` |
| Anti-flicker minimum spinner time | `future.minWait(duration)` |
| Timeout as null instead of an exception | `future.timeoutOrNull(duration)` |

## Debounce

```dart
final debounced = TimeUtils.debounce(
  () => runSearch(query),          // FutureOr<void> Function()
  const Duration(milliseconds: 300),
  maxWait: const Duration(seconds: 2), // must be > delay when set
  immediate: false,                    // true = leading edge
);
debounced();          // call it like a function
await debounced.flush(); // run the pending action NOW
debounced.cancel();   // drop the pending action
debounced.dispose();  // REQUIRED cleanup (idempotent)
```

- Returned type is `DebouncedCallback` (`call`, `flush`, `cancel`,
  `dispose`, `isRunning`, `isDisposed`).
- For pause/resume, observability, or history, construct `Debouncer`
  directly: `run(action)`, `flush()`, `tryFlush()`, `runIfNotPending()`,
  `cancel()`, `reset()`, `pause()`, `resume()`, `dispose()`, plus
  `stateStream` (broadcast `Stream<DebouncerState>`), `executionCount`,
  `remainingTime`, `remainingMaxWait`, `isPaused`.
- `Debouncer` validates `delay > 0`, `maxWait > delay`, and throws
  `StateError` if used after `dispose()`. `stateStream` is closed by
  `dispose()` - in Flutter, dispose in `State.dispose()`.

## Throttle

```dart
final throttled = TimeUtils.throttle(
  onScroll,                       // void Function()
  const Duration(milliseconds: 200),
  leading: true,                  // default
  trailing: false,                // DEFAULT false: burst calls are DROPPED
);
throttled();
throttled.cancel();   // drop pending trailing call
throttled.dispose();  // REQUIRED cleanup
```

- Returned type is `ThrottledCallback` - NOT `ThrottledFunction`; `cancel`
  and `dispose` are separate members and dispose is the terminal one.
- Set `trailing: true` when the LAST call of a burst must run; the default
  leading-only mode silently drops it.

## Streams

- `bufferCount(int count)` - emits `List<T>`; flushes the remainder on done;
  throws `ArgumentError` when count <= 0.
- `window(Duration)` - time-based batches.
- `rateLimit(int maxEvents, Duration duration)` - positional args (there is
  no `per:` parameter); events beyond the cap inside a window are DROPPED.
- `asPausable()` returns `PausableStream<T>`: listen on `.stream`, control
  with `pause()`/`resume()` (events are held with backpressure, not lost);
  cleanup happens when the subscription on `.stream` is cancelled.
- `withLatestValue()` - behavior-subject wrapper; internally broadcast.
- Error recovery on `Stream<T>`: `replaceOnError({required T defaultValue})`
  (emit default, then close) and `completeOnError()` (swallow, close).
- RETRY TRAP: `stream.retry(...)` on an already-listened single-subscription
  stream throws `StateError`. For single-subscription sources, retry the
  FACTORY instead:

```dart
Stream<T> Function() make = () => openSocket();
final resilient = make.retry(
  retryCount: 3,                          // NOT "retries"
  delayFactor: const Duration(seconds: 1), // exponential base
  shouldRetry: (e) => e is SocketException, // NOT "retryIf"
);
```

- `StreamController<T>` safety: `safeAdd(event)`/`safeAddError(e)` return
  bool instead of throwing on a closed controller; `safeClose()`,
  `safeAddAll(events, {throttleDuration})`, `safeAddStream(source)`,
  `mergeStreams(list)`, `asBroadcast()`.

## Futures and bounded concurrency

- `future.minWait(duration)` and `future.timeoutOrNull(duration)`.
- Retry is an extension on the FUNCTION type, and stream/future retry use
  DIFFERENT parameter names:

```dart
final data = await (() => api.fetch()).retry(
  retries: 3,                            // future version
  delay: const Duration(seconds: 1),     // doubles each attempt (2^n)
  retryIf: (e) => e is TimeoutException,
);
```

- `waitConcurrency` lives on `Iterable<Future<T> Function()>` (thunks, so
  starts can be gated), not on `Iterable<Future>`:

```dart
final tasks = urls.map((u) => () => fetch(u));
final results = await tasks.waitConcurrency(concurrency: 5);
```

- `items.mapConcurrent(action, {parallelism = 1})` maps with a limit; note
  `parallelism:` here vs `concurrency:` on waitConcurrency.
- ORDERING TRAP: both `waitConcurrency` and `mapConcurrent` return results
  in COMPLETION order, not input order. If order matters, carry the index:

```dart
final indexed = await items
    .mapIndexed((i, e) => () async => (i, await process(e)))
    .waitConcurrency(concurrency: 4);
indexed.sortBy<num>((r) => r.$1);
```

- `TimeUtils.runWithTimeout(task: ..., timeout: ...)` is a SOFT deadline: on
  timeout it completes with `TimeoutException` but the task keeps running in
  the background with its late errors swallowed. Do not use it to cancel
  work; pair it with a `Completer` if you must observe late completion.
- Measurement helpers: `TimeUtils.executionDuration(task)`,
  `executionDurations(tasks)`, `compareExecutionTimes(taskA:, taskB:)`,
  `runPeriodically(interval:, onExecute: (timer, count) {...})`.

## Step 0: Inspect the project first

1. Resolved version: `grep -A2 'dart_helper_utils' pubspec.lock` (this skill
   documents 6.x; TimeUtils.throttle had a DIFFERENT signature in 5.x).
2. In Flutter, find where the enclosing State/BLoC disposes resources and
   wire `dispose()` of any Debouncer/DebouncedCallback/ThrottledCallback
   there; creating them per-build is a leak.

## Verification

- `dart analyze` the touched paths; run the project's tests.
- For new debounce/throttle code, add a fake-async or short-real-delay test
  that asserts the collapsed call count, and a test that `dispose()` is
  reached (leaked timers keep test processes alive - a hanging test run is
  the symptom).

## Failure handling

- "Stream has already been listened to" or a StateError naming the retry
  extension: you retried a listened single-subscription stream - switch to
  the factory form above.
- Results in unexpected order after waitConcurrency/mapConcurrent: that is
  the documented completion-order contract; index-tag as shown.
- Undefined member errors: check the resolved version; 5.x names differ
  (use the migrate-dart-helper-utils-v5-to-v6 skill).
- For non-async utility APIs (strings, maps, dates, formatting), use the
  use-dart-helper-utils skill.
