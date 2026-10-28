---
name: async-with-dart-helper-utils
description: Use when Dart/Flutter code in a project that depends on the dart_helper_utils package needs debouncing, throttling, stream shaping, or bounded-concurrency async work - search-input debounce, rate-limited event streams, Debouncer/DebouncedCallback/Throttler lifecycle and disposal, TimeUtils.debounce/throttle/runWithTimeout, stream bufferCount/window/rateLimit/asPausable/withLatestValue/retry/replaceOnError, StreamController safeAdd/safeClose, Future minWait/timeoutOrNull, retry with exponential backoff, waitConcurrency, or mapConcurrent.
---

# Async, timing, and streams with dart_helper_utils

These APIs carry lifecycle and ordering semantics that agents reliably get
wrong from memory (wrong names, wrong parameter names, missed disposal,
wrong result ordering). Use the exact contracts below.

## Step 0: Inspect the project first

1. Resolved version:
   `dart pub deps --style=compact | grep '^- dart_helper_utils '`
   (`flutter pub deps` in a Flutter app). This skill documents 7.x;
   `preserveOrder` and the typed `executionHistory` are 7.0 additions, and
   `TimeUtils.throttle` had a DIFFERENT signature in 5.x.
2. In Flutter, find where the enclosing State/BLoC disposes resources and
   wire `dispose()` of any Debouncer/DebouncedCallback/Throttler/
   ThrottledCallback there; creating them per build is a leak.

## Choosing the right primitive

| Need | Use |
|---|---|
| Collapse a burst into one trailing call (search input) | `TimeUtils.debounce(fn, duration)` or a `Debouncer` you manage |
| At most one call per interval (scroll, resize) | `TimeUtils.throttle(fn, interval, trailing: ...)` or a `Throttler` you manage |
| Cap a STREAM's event rate | `stream.rateLimit(maxEvents, window)` - overflow events are DROPPED, not queued |
| Batch stream events by count / by time | `bufferCount(n)` / `window(duration)` |
| Hold stream events while the consumer is busy | `stream.asPausable()` |
| Late subscribers need the last value | `stream.withLatestValue()` |
| Bound how many futures run at once | `thunks.waitConcurrency(concurrency: 5)` or `items.mapConcurrent(fn, parallelism: 3)`; add `preserveOrder: true` for input-order results |
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
- `immediate: true` runs the FIRST call of a burst and skips the trailing
  call; a `maxWait` timer can still fire during a long burst.
- For pause/resume, observability, or history, construct `Debouncer`
  directly: `run(action)`, `flush()`, `tryFlush()`, `runIfNotPending()`,
  `cancel()`, `reset()`, `pause()`, `resume()`, `dispose()`, plus
  `stateStream` (broadcast `Stream<DebouncerState>`), `executionCount`,
  `remainingTime`, `remainingMaxWait` (both FROZEN while paused, `null` when
  nothing is scheduled), `isPaused`.
- `executionHistory` (only with `maxHistorySize > 0`) is an unmodifiable
  `List<DebouncerExecutionRecord>`: `startTime`, `endTime`, `duration`,
  `success`, `error`, and `toMap()` for logging. Before 7.0 it was a list of
  maps.
- `DebouncerState` has value equality (`==`/`hashCode`) and `copyWith`; since
  7.0 it is a plain immutable class, not an `Equatable`.
- `Debouncer` validates `delay > 0` and `maxWait > delay`. After
  `dispose()`, `run`, `flush`, `cancel`, and the other members throw
  `StateError`; only `dispose()` itself is safe to repeat. `stateStream` is
  closed by `dispose()` - in Flutter, dispose in `State.dispose()`.

## Throttle

```dart
final throttled = TimeUtils.throttle(
  onScroll,                       // FutureOr<void> Function(); async is fine
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
- For a throttler you own, construct
  `Throttler(interval: ..., leading: true, trailing: false, onError: ...)`
  and use `run(action)`, `cancel()`, `dispose()`, `isThrottled`, and
  `isDisposed`. `run` after `dispose()` throws `StateError`; `cancel()` and
  `dispose()` are no-ops then.
- Set `trailing: true` when the LAST call of a burst must run; the default
  leading-only mode silently drops it.
- Errors (sync or async) go to `onError`; without one they surface in the
  current zone with their original stack trace.

## Streams

- `bufferCount(int count)` - emits `List<T>`; flushes the remainder on done;
  throws `ArgumentError` when count <= 0. State is per subscription: each
  listener of a broadcast stream gets its own batches.
- `window(Duration)` - time-based batches.
- `rateLimit(int maxEvents, Duration duration)` - positional args (there is
  no `per:` parameter); events beyond the cap inside a window are DROPPED.
  The source is listened to only when the result is; pause and cancel
  propagate to it; each broadcast listener gets its own budget, and the
  result is broadcast when the source is.
- `asPausable()` returns `PausableStream<T>`: listen on `.stream`, control
  with `pause()`/`resume()`. While paused, events are BUFFERED IN MEMORY and
  delivered in order on `resume()`; the source keeps producing, so this is
  not backpressure and an endless source grows the buffer. Cleanup happens
  when the subscription on `.stream` is cancelled.
- `withLatestValue()` - behavior-subject wrapper; internally broadcast.
- Error recovery on `Stream<T>`: `replaceOnError({required T defaultValue})`
  (emit default, then close) and `completeOnError()` (swallow, close).
- RETRY TRAP: `stream.retry(...)` can only retry BROADCAST streams. On any
  single-subscription stream, even a fresh one, the first retry throws
  `StateError` because the stream cannot be listened to twice. Retry the
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
  in COMPLETION order by default, not input order. Since 7.0, pass
  `preserveOrder: true` when order matters (same concurrency limit):

```dart
final pages = await urls.mapConcurrent(
  fetch,
  parallelism: 4,
  preserveOrder: true,
);
```

- `TimeUtils.runWithTimeout(task: ..., timeout: ...)` is a SOFT deadline: on
  timeout it completes with `TimeoutException` but the task keeps running in
  the background with its late errors swallowed. Do not use it to cancel
  work; pair it with a `Completer` if you must observe late completion.
- Measurement helpers: `TimeUtils.executionDuration(task)`,
  `executionDurations(tasks)`, `compareExecutionTimes(taskA:, taskB:)`,
  `runPeriodically(interval:, onExecute: (timer, count) {...})`.

## Verification

- `dart analyze` the touched paths; run the project's tests.
- For new debounce/throttle code, add a fake-async or short-real-delay test
  that asserts the collapsed call count, and a test that `dispose()` is
  reached (leaked timers keep test processes alive - a hanging test run is
  the symptom).

## Failure handling

- "Stream has already been listened to" or a StateError from the retry
  extension: you retried a single-subscription stream - switch to the
  factory form above.
- `StateError` mentioning dispose: a Debouncer or Throttler was used after
  `dispose()`; check the owner's lifecycle.
- Results in unexpected order after waitConcurrency/mapConcurrent: that is
  the documented completion-order default; pass `preserveOrder: true`.
- Undefined member errors: check the resolved version; 6.x lacks the 7.0
  additions (migrate-dart-helper-utils-v6-to-v7) and 5.x names differ
  (migrate-dart-helper-utils-v5-to-v6).
- For non-async utility APIs (strings, maps, dates, formatting), use the
  use-dart-helper-utils skill.

## When NOT to use

- A project that does not depend on dart_helper_utils: do not add the
  package only for one debounce or throttle; a `Timer` or the project's
  existing reactive library is enough.
