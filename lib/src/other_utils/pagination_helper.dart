import 'dart:async';
import 'dart:math';

import 'package:async/async.dart';
import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:meta/meta.dart';

/// Configuration that allows tweaking retry logic, caching, and other pagination behaviors.
///
/// Example:
/// ```dart
/// final config = PaginationConfig(
///   retryAttempts: 5,
///   retryDelay: Duration(seconds: 2),
///   cacheTimeout: Duration(minutes: 10),
///   autoCancelFetches: false,
///   maxCacheSize: 50,
/// );
/// ```
class PaginationConfig {
  /// Creates a [PaginationConfig] with optional parameters.
  ///
  /// - [retryAttempts]: Number of retry attempts after a page load fails. Defaults to 3.
  /// - [retryDelay]: Duration to wait between retries. Defaults to 1 second.
  /// - [cacheTimeout]: Duration before cached pages expire. Defaults to 5 minutes.
  /// - [autoCancelFetches]: If true, cancels any ongoing fetch before starting a new one. Defaults to true.
  const PaginationConfig({
    this.retryAttempts = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.cacheTimeout = const Duration(minutes: 5),
    this.autoCancelFetches = true,
    this.maxCacheSize = 100,
  });

  /// Number of times to retry fetching a page after a failure.
  final int retryAttempts;

  /// Base duration to wait between retry attempts (exponentially scaled).
  final Duration retryDelay;

  /// Duration before cached pages expire.
  final Duration cacheTimeout;

  /// If true, cancels any ongoing fetch before starting a new one.
  final bool autoCancelFetches;

  /// Maximum number of cached entries allowed.
  final int maxCacheSize;
}

/// Exception thrown when pagination operations fail.
///
/// Contains an error message and optionally the original error.
class PaginationException implements Exception {
  /// Creates a [PaginationException] with a message and an optional original error.
  PaginationException(this.message, {this.originalError});

  /// A descriptive error message.
  final String message;

  /// The original error, if available.
  final Object? originalError;

  @override
  String toString() {
    final suffix = originalError != null ? ' (Original: $originalError)' : '';
    return 'PaginationException: $message$suffix';
  }
}

/// Internal cache entry used for caching pages or transformed paginators.
///
/// This is not part of the public API.
class _CacheEntry<V> {
  _CacheEntry(this.data) : createdAt = DateTime.now();

  /// The cached data.
  final V data;

  /// Timestamp when the data was cached.
  final DateTime createdAt;
}

/// Basic interface that any paginator should implement.
///
/// This interface defines the essential operations for pagination,
/// such as navigating pages and retrieving current page items.
abstract class IPaginator<T> {
  /// The number of items per page.
  int get pageSize;

  /// Sets the number of items per page. Must be greater than 0.
  set pageSize(int value);

  /// The current page number (starting at 1).
  int get currentPage;

  /// Indicates whether there is a next page.
  FutureOr<bool> get hasNextPage;

  /// Indicates whether there is a previous page.
  bool get hasPreviousPage;

  /// Jumps directly to the specified [pageNumber].
  ///
  /// Throws a [StateError] if the paginator has been disposed.
  void goToPage(int pageNumber);

  /// Moves to the next page if it exists.
  ///
  /// Returns `true` if the page was changed, otherwise `false`.
  FutureOr<bool> nextPage();

  /// Moves to the previous page if it exists.
  ///
  /// Returns `true` if the page was changed, otherwise `false`.
  FutureOr<bool> previousPage();

  /// Resets the paginator to its initial state (e.g., first page).
  void reset();

  /// Retrieves the items for the current page.
  FutureOr<List<T>> get currentPageItems;

  /// Returns `true` if the paginator has been disposed.
  bool get isDisposed;
}

/// Base class for paginators that provides shared logic, debouncing, and disposal checks.
///
/// Subclasses must call [dispose] when no longer needed to free resources.
abstract class BasePaginator<T> implements IPaginator<T> {
  /// Creates a [BasePaginator] with the specified [initialPageSize] and optional [config].
  ///
  /// Throws an [ArgumentError] if [initialPageSize] is not greater than 0.
  BasePaginator({
    required int initialPageSize,
    this.config = const PaginationConfig(),
  }) : _pageSize = initialPageSize {
    if (initialPageSize <= 0) {
      throw ArgumentError('initialPageSize must be > 0');
    }
  }

  /// Configuration for pagination behavior.
  final PaginationConfig config;

  final StreamController<String> _lifecycleController =
      StreamController<String>.broadcast();

  /// A broadcast stream of lifecycle events (e.g., "pageChanged", "reset").
  Stream<String> get lifecycleStream => _lifecycleController.stream;

  /// Emits a lifecycle event.
  @protected
  void emitLifecycleEvent(String eventName) {
    if (!_lifecycleController.isClosed) {
      _lifecycleController.add(eventName);
    }
  }

  int _pageSize;
  int _currentPage = 1;
  Timer? _debounceTimer;

  /// The most recent error encountered during pagination operations.
  Exception? lastError;

  bool _isDisposed = false;

  /// Ensures the paginator is not disposed. Throws a [StateError] if disposed.
  @protected
  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('Paginator has been disposed');
    }
  }

  @override
  int get pageSize => _pageSize;

  @override
  set pageSize(int value) {
    _ensureNotDisposed();
    if (value <= 0) {
      throw ArgumentError('pageSize must be > 0');
    }
    if (value != _pageSize) {
      _pageSize = value;
      // Reset the current page to maintain consistency.
      _currentPage = 1;
      onPageSizeChanged(value);
      emitLifecycleEvent('pageSizeChanged');
    }
  }

  /// Called when the page size has changed.
  @protected
  void onPageSizeChanged(int newSize) {}

  @override
  int get currentPage => _currentPage;

  @override
  bool get hasPreviousPage => _currentPage > 1;

  @override
  void goToPage(int pageNumber) {
    if (isDisposed) return; // If disposed, do nothing.
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (isDisposed) return; // Check again inside the timer.
      final pn = pageNumber < 1 ? 1 : pageNumber;
      if (pn != _currentPage) {
        _currentPage = pn;
        onPageChanged(pn);
        emitLifecycleEvent('pageChanged');
      }
    });
  }

  /// Called when the current page changes.
  @protected
  void onPageChanged(int newPage) {}

  @override
  void reset() {
    _ensureNotDisposed();
    _currentPage = 1;
    lastError = null;
    onReset();
    emitLifecycleEvent('reset');
  }

  /// Called when the paginator is reset.
  @protected
  void onReset() {}

  @override
  bool get isDisposed => _isDisposed;

  /// Disposes of resources used by the paginator, such as timers and stream controllers.
  ///
  /// This method must be called when the paginator is no longer needed to free up resources and
  /// avoid memory leaks. Once [dispose] is called, the paginator is considered disposed and any
  /// further operations on it may throw a [StateError]. Subclasses that override [dispose] should
  /// call `super.dispose()` to ensure proper cleanup.
  ///
  /// The method checks if the paginator has already been disposed (using the [_isDisposed] flag)
  /// to prevent multiple disposals.
  @mustCallSuper
  void dispose() {
    if (_isDisposed) return;
    _debounceTimer?.cancel();
    _lifecycleController.close();
    _isDisposed = true;
  }
}

/// Mixin that provides analytics tracking for pagination operations.
///
/// Tracks page load events, errors, and cache hits.
mixin PaginationAnalytics<T> on BasePaginator<T> {
  final _metrics = <String, int>{
    'pageLoads': 0,
    'errors': 0,
    'cacheHits': 0,
  };

  /// Returns an unmodifiable map of collected metrics.
  Map<String, int> get metrics => Map.unmodifiable(_metrics);

  /// Logs a page load event.
  void logPageLoad() =>
      _metrics['pageLoads'] = (_metrics['pageLoads'] ?? 0) + 1;

  /// Logs an error event.
  void logError() => _metrics['errors'] = (_metrics['errors'] ?? 0) + 1;

  /// Logs a cache hit event.
  void logCacheHit() =>
      _metrics['cacheHits'] = (_metrics['cacheHits'] ?? 0) + 1;
}

/// Synchronous, in-memory paginator that paginates a provided list of items.
///
/// This paginator slices a full list into pages and supports transformation,
/// filtering, and sorting with caching.
class Paginator<T> extends BasePaginator<T> with PaginationAnalytics<T> {
  /// Creates a new [Paginator] with a list of [items].
  ///
  /// [pageSize] determines the number of items per page. If not specified, defaults to 10.
  /// [config] can be provided to customize pagination behavior.
  Paginator({
    required this.items,
    int pageSize = 10,
    PaginationConfig? config,
  }) : super(
          initialPageSize: pageSize,
          config: config ?? const PaginationConfig(),
        );

  /// The complete list of items to paginate.
  final List<T> items;

  /// Cache for storing transformed paginators.
  final Map<Object, _CacheEntry<Paginator<T>>> _transformCache = {};

  /// Evicts the oldest cache entry if the cache exceeds the maximum allowed size.
  void _evictOldCacheEntries() {
    if (_transformCache.length > config.maxCacheSize) {
      Object? oldestKey;
      DateTime? oldestDate;
      _transformCache.forEach((key, entry) {
        if (oldestDate == null || entry.createdAt.isBefore(oldestDate!)) {
          oldestDate = entry.createdAt;
          oldestKey = key;
        }
      });
      if (oldestKey != null) {
        _transformCache.remove(oldestKey);
      }
    }
  }

  @override
  List<T> get currentPageItems {
    _ensureNotDisposed();
    if (items.isEmpty) return const [];
    final total = totalItems;
    final totalPages =
        (total / pageSize).ceil().clamp(1, double.infinity).toInt();
    if (currentPage > totalPages) {
      goToPage(totalPages);
    }
    final startIndex = (currentPage - 1) * pageSize;
    final endIndex = min(startIndex + pageSize, total);
    try {
      return items.sublist(startIndex, endIndex);
    } catch (e) {
      lastError = PaginationException('Error slicing items', originalError: e);
      throw lastError!;
    }
  }

  /// Total number of items available.
  int get totalItems => items.length;

  /// Total number of pages.
  int get totalPages => totalItems == 0 ? 1 : (totalItems / pageSize).ceil();

  @override
  bool get hasNextPage => currentPage < totalPages;

  @override
  bool nextPage() {
    _ensureNotDisposed();
    if (hasNextPage) {
      goToPage(currentPage + 1);
      return true;
    }
    return false;
  }

  @override
  bool previousPage() {
    _ensureNotDisposed();
    if (hasPreviousPage) {
      goToPage(currentPage - 1);
      return true;
    }
    return false;
  }

  /// Clears all cached transformations.
  void clearTransforms() {
    _ensureNotDisposed();
    _transformCache.clear();
  }

  @override
  @mustCallSuper
  void onReset() {
    super.onReset();
    clearTransforms();
  }

  @override
  @mustCallSuper
  void dispose() {
    if (_isDisposed) return;
    clearTransforms();
    super.dispose();
  }

  /// Creates a new paginator by applying a transformation function to each item.
  ///
  /// Returns a new [Paginator] containing items of type [R].
  Paginator<R> map<R>(R Function(T) transform) {
    _ensureNotDisposed();
    final transformedItems = items.map(transform).toList();
    return Paginator<R>(
      items: transformedItems,
      pageSize: pageSize,
      config: config,
    );
  }

  /// Creates a new paginator by filtering items with [predicate].
  ///
  /// Optionally provide a [cacheKey] to reuse previous filter results.
  Paginator<T> where(bool Function(T) predicate, {Object? cacheKey}) {
    _ensureNotDisposed();
    final key = cacheKey ?? predicate.hashCode;
    final cacheEntry = _transformCache[key];
    if (cacheEntry != null) {
      final isExpired =
          DateTime.now().difference(cacheEntry.createdAt) > config.cacheTimeout;
      if (!isExpired) {
        logCacheHit();
        return cacheEntry.data;
      } else {
        _transformCache.remove(key);
      }
    }
    final filtered = items.where(predicate).toList();
    final newPaginator = Paginator<T>(
      items: filtered,
      pageSize: pageSize,
      config: config,
    );
    _transformCache[key] = _CacheEntry<Paginator<T>>(newPaginator);
    _evictOldCacheEntries();
    return newPaginator;
  }

  /// Creates a new paginator by sorting items with the provided [compare] function.
  ///
  /// Optionally provide a [cacheKey] to reuse previous sort results.
  Paginator<T> sort(int Function(T a, T b) compare, {Object? cacheKey}) {
    _ensureNotDisposed();
    final key = cacheKey ?? compare.hashCode;
    final cacheEntry = _transformCache[key];
    if (cacheEntry != null) {
      final isExpired =
          DateTime.now().difference(cacheEntry.createdAt) > config.cacheTimeout;
      if (!isExpired) {
        logCacheHit();
        return cacheEntry.data;
      } else {
        _transformCache.remove(key);
      }
    }
    final sortedItems = List<T>.from(items)..sort(compare);
    final newPaginator = Paginator<T>(
      items: sortedItems,
      pageSize: pageSize,
      config: config,
    );
    _transformCache[key] = _CacheEntry<Paginator<T>>(newPaginator);
    _evictOldCacheEntries();
    return newPaginator;
  }

  /// Provides detailed information about the current pagination state.
  Map<String, dynamic> get pageInfo => {
        'currentPage': currentPage,
        'totalPages': totalPages,
        'pageSize': pageSize,
        'totalItems': totalItems,
        'hasNextPage': hasNextPage,
        'hasPreviousPage': hasPreviousPage,
      };
}

/// An asynchronous paginator that fetches pages using a provided [fetchPage] function.
///
/// This class handles request deduplication, caching, exponential backoff for retries,
/// and cancellation of ongoing requests. Always ensure you implement your [fetchPage]
/// function in a non-blocking, cancelable way.
///
/// **Usage Example:**
/// ```dart
/// Future<List<int>> fetchPage(int pageNumber, int pageSize) async {
/// 100.millisecondsDelay();
///   return List.generate(pageSize, (i) => (pageNumber - 1) * pageSize + i + 1);
/// }
///
/// final asyncPaginator = AsyncPaginator<int>(
///   fetchPage: fetchPage,
///   pageSize: 10,
/// );
/// final items = await asyncPaginator.currentPageItems;
/// ```
class AsyncPaginator<T> extends BasePaginator<T> {
  /// Creates an [AsyncPaginator] with the specified [fetchPage] function, optional [pageSize],
  /// [config], and an optional [totalItemsFetcher].
  AsyncPaginator({
    required this.fetchPage,
    int pageSize = 10,
    PaginationConfig? config,
    this.totalItemsFetcher,
  }) : super(
          initialPageSize: pageSize,
          config: config ?? const PaginationConfig(),
        );

  /// Function to fetch a page.
  ///
  /// Must return a [Future] that completes with a list of items.
  final Future<List<T>> Function(int pageNumber, int pageSize) fetchPage;

  /// Optional function to fetch the total number of items.
  final Future<int> Function()? totalItemsFetcher;

  final Map<int, _CacheEntry<List<T>>> _pageCache = {};
  final Map<int, PageState> _pageStates = {};
  final StreamController<Map<String, dynamic>> _stateController =
      StreamController.broadcast();
  CancelableOperation<List<T>>? _ongoingFetch;
  final Map<int, Future<List<T>>> _requestCache = {};

  /// A broadcast stream of page state changes.
  Stream<Map<String, dynamic>> get stateStream => _stateController.stream;

  /// Returns `true` if the current page is loading.
  bool get isLoading => getPageState(currentPage) == PageState.loading;

  void _emitPageState(int page, PageState state) {
    _pageStates[page] = state;
    _stateController.add({'page': page, 'state': state});
  }

  /// Returns the current state of a given page.
  PageState getPageState(int page) => _pageStates[page] ?? PageState.initial;

  @override
  Future<bool> get hasNextPage async {
    _ensureNotDisposed();
    if (totalItemsFetcher != null) {
      final total = await totalItemsFetcher!();
      return currentPage * pageSize < total;
    }
    try {
      final peekItems = await fetchPage(currentPage + 1, 1);
      return peekItems.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<T>> get currentPageItems async {
    _ensureNotDisposed();
    final page = currentPage;
    final cacheEntry = _pageCache[page];
    if (cacheEntry != null) {
      final age = DateTime.now().difference(cacheEntry.createdAt);
      if (age < config.cacheTimeout) return cacheEntry.data;
      _pageCache.remove(page);
    }
    if (_requestCache.containsKey(page)) {
      return _requestCache[page]!;
    }
    if (config.autoCancelFetches && _ongoingFetch != null) {
      await _ongoingFetch?.cancel();
      _ongoingFetch = null;
    }
    _emitPageState(page, PageState.loading);
    lastError = null;
    Future<List<T>> fetchOperation() async {
      var attempts = 0;
      while (attempts < config.retryAttempts) {
        attempts++;
        try {
          final operation = CancelableOperation<List<T>>.fromFuture(
            fetchPage(page, pageSize),
          );
          _ongoingFetch = operation;
          final items = await operation.valueOrCancellation();
          if (items == null) {
            throw PaginationException('Fetch for page $page was canceled');
          }
          _pageCache[page] = _CacheEntry<List<T>>(items);
          _emitPageState(page, PageState.loaded);
          return items;
        } catch (e) {
          if (attempts >= config.retryAttempts) {
            lastError = PaginationException(
              'Failed to fetch page $page after $attempts attempts',
              originalError: e,
            );
            _emitPageState(page, PageState.error);
            throw lastError!;
          }
          final delayMillis =
              config.retryDelay.inMilliseconds * (1 << (attempts - 1));
          await delayMillis.millisecondsDelay();
        }
      }
      throw StateError('Unexpected: fell through retry loop');
    }

    final future = fetchOperation();
    _requestCache[page] = future;
    await future.whenComplete(() => _requestCache.remove(page));
    return future;
  }

  @override
  Future<bool> nextPage() async {
    _ensureNotDisposed();
    if (await hasNextPage) {
      goToPage(currentPage + 1);
      return true;
    }
    return false;
  }

  @override
  Future<bool> previousPage() async {
    _ensureNotDisposed();
    if (hasPreviousPage) {
      goToPage(currentPage - 1);
      return true;
    }
    return false;
  }

  /// Clears all cached pages and page states.
  void clearCache() {
    _ensureNotDisposed();
    _pageCache.clear();
    _pageStates.clear();
  }

  @override
  @mustCallSuper
  void onReset() {
    super.onReset();
    clearCache();
  }

  @override
  @mustCallSuper
  void dispose() {
    if (_isDisposed) return;
    _ongoingFetch?.cancel();
    _stateController.close();
    clearCache();
    super.dispose();
  }
}

/// A generic "cursor" used for cursor-based pagination.
///
/// Immutable to ensure consistency.
@immutable
class PaginationCursor<T> {
  /// Creates a [PaginationCursor] with the provided [value].
  const PaginationCursor(this.value);

  /// The value representing the current position.
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaginationCursor<T> && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

/// An infinite paginator that supports continuous loading of items.
///
/// This paginator supports both page-based and cursor-based approaches.
/// It continuously loads more items until no more data is available.
///
/// **Usage Examples:**
///
/// *Page-based*
/// ```dart
/// Future<List<int>> fetchItems(int pageSize, int pageNumber) async {
/// 100.millisecondsDelay();
///   if (pageNumber > 5) return []; // No more data after page 5.
///   return List.generate(pageSize, (i) => (pageNumber - 1) * pageSize + i + 1);
/// }
///
/// final infinitePaginator = InfinitePaginator.pageBased(
///   fetchItems: fetchItems,
///   pageSize: 10,
///   initialPageNumber: 1,
/// );
/// await infinitePaginator.loadMoreItems();
/// print(infinitePaginator.items);
/// ```
///
/// *Cursor-based*
/// ```dart
/// Future<List<String>> fetchItems(
///   int pageSize,
///   PaginationCursor<String> cursor,
/// ) async {
/// 100.millisecondsDelay();
///   if (cursor.value == 'end') return [];
///   return List.generate(pageSize, (i) => '${cursor.value}_item${i + 1}');
/// }
///
/// PaginationCursor<String> getNextCursor(List<String> items) {
///   return items.isNotEmpty ? PaginationCursor('next') : PaginationCursor('end');
/// }
///
/// final infinitePaginator = InfinitePaginator.cursorBased(
///   fetchItems: fetchItems,
///   getNextCursor: getNextCursor,
///   pageSize: 5,
///   initialCursor: PaginationCursor('start'),
/// );
/// await infinitePaginator.loadMoreItems();
/// print(infinitePaginator.items);
/// ```
class InfinitePaginator<T, C> {
  InfinitePaginator._({
    required this.fetchItems,
    required this.updatePaginationKey,
    required this.pageSize,
    required this.initialKey,
    this.config = const PaginationConfig(),
  }) {
    _currentKey = initialKey;
  }

  /// Factory constructor for a page-based infinite paginator.
  ///
  /// [fetchItems] is called with the [pageSize] and page number.
  /// [initialPageNumber] defines the starting page (defaults to 1).
  /// [config] can be used to customize pagination behavior.
  factory InfinitePaginator.pageBased({
    required Future<List<T>> Function(int pageSize, int pageNumber) fetchItems,
    int pageSize = 20,
    int initialPageNumber = 1,
    PaginationConfig? config,
  }) {
    return InfinitePaginator._(
      fetchItems: (size, key) => fetchItems(size, key as int),
      updatePaginationKey: (items, oldKey) => (oldKey as int) + 1,
      pageSize: pageSize,
      initialKey: initialPageNumber,
      config: config ?? const PaginationConfig(),
    );
  }

  /// Factory constructor for a cursor-based infinite paginator.
  ///
  /// [fetchItems] is called with the [pageSize] and a [PaginationCursor].
  /// [getNextCursor] determines the next cursor value from the fetched items.
  /// [initialCursor] must be provided for non-int cursor types.
  factory InfinitePaginator.cursorBased({
    required Future<List<T>> Function(int pageSize, PaginationCursor<C> cursor)
        fetchItems,
    required PaginationCursor<C> Function(List<T> newItems) getNextCursor,
    int pageSize = 20,
    PaginationCursor<C>? initialCursor,
    PaginationConfig? config,
  }) {
    final initial = initialCursor ??
        (() {
          if (C == int) return PaginationCursor<C>(0 as C);
          throw ArgumentError(
              'initialCursor must be provided for non-int cursor types');
        }());
    return InfinitePaginator._(
      fetchItems: (size, key) => fetchItems(size, key as PaginationCursor<C>),
      updatePaginationKey: (items, oldKey) => getNextCursor(items),
      pageSize: pageSize,
      initialKey: initial,
      config: config ?? const PaginationConfig(),
    );
  }

  /// Internal list that stores all loaded items.
  final List<T> _items = [];

  /// Function that fetches items based on the given [pageSize] and a dynamic [paginationKey].
  ///
  /// This function must return a [Future] that completes with a [List] of items.
  final Future<List<T>> Function(int pageSize, dynamic paginationKey)
      fetchItems;

  /// Function that updates the pagination key based on the newly fetched [items] and the current key ([currentKey]).
  ///
  /// This is used to generate the next key required to fetch subsequent pages.
  final dynamic Function(List<T> items, dynamic currentKey) updatePaginationKey;

  /// Configuration options for pagination behavior.
  ///
  /// This includes settings for retry attempts, retry delay, caching, and other pagination parameters.
  final PaginationConfig config;

  /// Number of items to fetch per request (i.e., the page size).
  final int pageSize;

  /// The initial pagination key used when starting pagination (e.g., initial page number or cursor).
  final dynamic initialKey;

  /// The current pagination key, updated after each successful fetch operation.
  ///
  /// This key is used by [fetchItems] to fetch the next set of items.
  dynamic _currentKey;

  /// Flag indicating whether a fetch operation is currently in progress.
  bool _isLoading = false;

  /// Flag indicating whether there are more items available to be loaded.
  ///
  /// When set to `false`, no further fetches will occur.
  bool _hasMoreItems = true;

  /// Holds the most recent error encountered during a fetch operation, if any.
  Exception? lastError;

  /// A broadcast [StreamController] that emits loading state changes.
  ///
  /// It emits `true` when a fetch operation starts and `false` when it ends.
  final StreamController<bool> _loadingController =
      StreamController<bool>.broadcast();

  /// Reference to the current ongoing fetch operation as a [CancelableOperation].
  ///
  /// This allows cancellation of the fetch operation if needed.
  CancelableOperation<List<T>>? _ongoingFetch;

  /// Stream that notifies listeners about loading state changes.
  Stream<bool> get loadingStream => _loadingController.stream;

  /// Unmodifiable list of loaded items.
  List<T> get items => List.unmodifiable(_items);

  /// Indicates whether a fetch operation is in progress.
  bool get isLoading => _isLoading;

  /// Indicates whether there are more items to load.
  bool get hasMoreItems => _hasMoreItems;

  /// Total number of items loaded.
  int get itemCount => _items.length;

  /// Loads more items into the paginator.
  ///
  /// Handles retry logic with exponential backoff, cancellation of ongoing requests,
  /// and updates the internal pagination key. If no more items are available, further
  /// calls will have no effect.
  Future<void> loadMoreItems() async {
    if (_isLoading || !_hasMoreItems) return;
    _isLoading = true;
    _loadingController.add(true);
    if (config.autoCancelFetches && _ongoingFetch != null) {
      await _ongoingFetch?.cancel();
      _ongoingFetch = null;
    }
    var attempts = 0;
    while (attempts < config.retryAttempts) {
      attempts++;
      try {
        final operation = CancelableOperation<List<T>>.fromFuture(
          fetchItems(pageSize, _currentKey),
        );
        _ongoingFetch = operation;
        final newItems = await operation.valueOrCancellation();
        if (newItems == null) {
          throw PaginationException('InfinitePaginator fetch canceled');
        }
        if (newItems.isEmpty) {
          _hasMoreItems = false;
        } else {
          _items.addAll(newItems);
          _currentKey = updatePaginationKey(newItems, _currentKey);
        }
        lastError = null;
        break;
      } catch (e) {
        if (attempts >= config.retryAttempts) {
          lastError = PaginationException(
            'Failed to load more items after $attempts attempts',
            originalError: e,
          );
          rethrow;
        }
        final delayMillis =
            config.retryDelay.inMilliseconds * (1 << (attempts - 1));
        await delayMillis.millisecondsDelay();
      } finally {
        _isLoading = false;
        _loadingController.add(false);
      }
    }
  }

  /// Retries loading more items if the last attempt resulted in an error.
  Future<void> retry() async {
    if (lastError != null) {
      await loadMoreItems();
    }
  }

  /// Resets the paginator to its initial state.
  ///
  /// Clears all loaded items and resets the internal pagination key.
  void reset() {
    _items.clear();
    _hasMoreItems = true;
    _isLoading = false;
    _currentKey = initialKey;
    lastError = null;
    _loadingController.add(false);
  }

  bool _isDisposed = false;

  /// Returns `true` if the infinite paginator has been disposed.
  bool get isDisposed => _isDisposed;

  /// Disposes of resources used by the infinite paginator.
  ///
  /// Must be called when the paginator is no longer needed to prevent memory leaks.
  void dispose() {
    if (_isDisposed) return;
    _ongoingFetch?.cancel();
    _loadingController.close();
    _items.clear();
    _isDisposed = true;
  }

  /// Returns the current state of the paginator as a [Map].
  ///
  /// Useful for debugging or logging.
  Map<String, dynamic> get state => {
        'itemCount': itemCount,
        'hasMoreItems': hasMoreItems,
        'isLoading': isLoading,
        'lastError': lastError?.toString(),
      };
}

/// Extension methods to transform fetched data in an [AsyncPaginator].
extension AsyncPaginatorTransform<T> on AsyncPaginator<T> {
  /// Returns a new [AsyncPaginator] that maps each fetched item using the [transform] function.
  ///
  /// The resulting paginator will contain items of type [R].
  AsyncPaginator<R> map<R>(R Function(T) transform) {
    return AsyncPaginator<R>(
      pageSize: pageSize,
      config: config,
      totalItemsFetcher: totalItemsFetcher,
      fetchPage: (pageNum, size) async {
        final data = await fetchPage(pageNum, size);
        return data.map(transform).toList();
      },
    );
  }

  /// Returns a new [AsyncPaginator] that filters each fetched page using the [predicate].
  ///
  /// The fetch operation retrieves twice the [pageSize] and applies the filter,
  /// returning only the first [pageSize] items that match the predicate.
  AsyncPaginator<T> where(bool Function(T) predicate) {
    return AsyncPaginator<T>(
      pageSize: pageSize,
      config: config,
      totalItemsFetcher: totalItemsFetcher,
      fetchPage: (pageNum, size) async {
        final data = await fetchPage(pageNum, size * 2);
        final filtered = data.where(predicate).take(size).toList();
        return filtered;
      },
    );
  }
}

/// Extension methods to perform validations on any [IPaginator].
///
/// Ensures that pagination parameters are within valid ranges.
extension PaginatorTesting<T> on IPaginator<T> {
  /// Validates the paginator's current state.
  ///
  /// Throws a [StateError] if the [pageSize] is less than or equal to 0 or if [currentPage] is less than 1.
  void validate() {
    if (pageSize <= 0) {
      throw StateError('Invalid pageSize: $pageSize');
    }
    if (currentPage < 1) {
      throw StateError('Invalid currentPage: $currentPage');
    }
    // Additional validations can be added here as needed.
  }
}

/// Describes the current loading state of a page.
///
/// Used by asynchronous paginators to report the status of page fetch operations.
enum PageState {
  /// Initial state before any data is fetched.
  initial,

  /// Indicates that the page is currently loading.
  loading,

  /// Indicates that the page has successfully loaded.
  loaded,

  /// Indicates that an error occurred while loading the page.
  error,
}
