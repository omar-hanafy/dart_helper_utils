import 'dart:async';

import 'package:async/async.dart';
import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:meta/meta.dart';

/// Describes the current loading state of a page.
enum PageState {
  /// Initial loading state before any data is fetched.
  initial,

  /// Indicates that the page is currently loading.
  loading,

  /// Indicates that the page has successfully loaded.
  loaded,

  /// Indicates that an error occurred while loading the page.
  error,
}

/// Configuration that allows tweaking retry logic, caching, and other pagination behaviors.
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
  });

  /// Number of times to retry fetching a page after a failure.
  final int retryAttempts;

  /// Duration to wait between retry attempts.
  final Duration retryDelay;

  /// Duration before cached pages expire.
  final Duration cacheTimeout;

  /// If true, any ongoing fetch is canceled before initiating a new one.
  final bool autoCancelFetches;
}

/// A custom exception class for handling pagination-related errors.
class PaginationException implements Exception {
  /// Creates a [PaginationException] with a message and an optional original error.
  PaginationException(this.message, {this.originalError});

  /// A descriptive message for the exception.
  final String message;

  /// The original error that caused this exception, if any.
  final Object? originalError;

  @override
  String toString() {
    final suffix = originalError != null ? ' (Original: $originalError)' : '';
    return 'PaginationException: $message$suffix';
  }
}

/// A simple cache entry containing data and a timestamp.
///
/// Used to manage the expiration of cached pages or transformed results.
class _CacheEntry<V> {
  /// Creates a [_CacheEntry] with the provided data.
  ///
  /// The [createdAt] timestamp is automatically set to the current time.
  _CacheEntry(this.data) : createdAt = DateTime.now();

  /// The cached data.
  final V data;

  /// The timestamp when the data was cached.
  final DateTime createdAt;
}

/// Basic interface that any paginator should implement.
abstract class IPaginator<T> {
  /// Number of items each page should contain.
  int get pageSize;

  /// Sets the number of items per page. Must be greater than 0.
  set pageSize(int value);

  /// The current page number, starting at 1.
  int get currentPage;

  /// Indicates whether there is another page available ahead.
  FutureOr<bool> get hasNextPage;

  /// Indicates whether there is a previous page available.
  bool get hasPreviousPage;

  /// Jumps directly to the specified [pageNumber].
  void goToPage(int pageNumber);

  /// Moves to the next page if it exists.
  ///
  /// Returns `true` if the page was changed, `false` otherwise.
  FutureOr<bool> nextPage();

  /// Moves to the previous page if it exists.
  ///
  /// Returns `true` if the page was changed, `false` otherwise.
  FutureOr<bool> previousPage();

  /// Resets the paginator to its initial state (e.g., first page).
  void reset();

  /// Retrieves the items for the current page.
  FutureOr<List<T>> get currentPageItems;
}

/// A helper base class that provides shared logic for both synchronous and asynchronous paginators.
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

  /// Stream controller for lifecycle events such as "pageChanged" or "reset".
  final StreamController<String> _lifecycleController =
      StreamController<String>.broadcast();

  /// Stream of lifecycle events that listeners can subscribe to.
  Stream<String> get lifecycleStream => _lifecycleController.stream;

  /// Emits a lifecycle event with the given [eventName].
  ///
  /// This helps listeners know what actions are occurring within the paginator.
  @protected
  void emitLifecycleEvent(String eventName) {
    if (!_lifecycleController.isClosed) {
      _lifecycleController.add(eventName);
    }
  }

  int _pageSize;
  int _currentPage = 1;

  /// Stores the most recent error to assist with debugging and logging.
  Exception? lastError;

  @override
  int get pageSize => _pageSize;

  @override
  set pageSize(int value) {
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
  ///
  /// Subclasses can override this method to implement custom logic.
  @protected
  void onPageSizeChanged(int newSize) {}

  @override
  int get currentPage => _currentPage;

  @override
  bool get hasPreviousPage => _currentPage > 1;

  @override
  void goToPage(int pageNumber) {
    var pn = pageNumber;
    // Clamp pageNumber to ensure it never goes below 1.
    if (pn < 1) pn = 1;
    if (pn != _currentPage) {
      _currentPage = pn;
      onPageChanged(pn);
      emitLifecycleEvent('pageChanged');
    }
  }

  /// Called when the current page changes.
  ///
  /// Subclasses can override this method to implement custom logic.
  @protected
  void onPageChanged(int newPage) {}

  @override
  void reset() {
    _currentPage = 1;
    lastError = null;
    onReset();
    emitLifecycleEvent('reset');
  }

  /// Called when the paginator is reset.
  ///
  /// Subclasses can override this method to clear resources or perform other reset actions.
  @protected
  void onReset() {
    // Subclasses can override if needed.
  }

  /// Disposes of resources such as streams or caches.
  ///
  /// Always call `super.dispose()` in overrides to ensure proper cleanup.
  @mustCallSuper
  void dispose() {
    _lifecycleController.close();
  }
}

/// A mixin that provides analytics tracking for pagination operations.
mixin PaginationAnalytics<T> on BasePaginator<T> {
  /// Internal metrics tracking various pagination events.
  final _metrics = <String, int>{
    'pageLoads': 0,
    'errors': 0,
    'cacheHits': 0,
  };

  /// Exposes the collected metrics as an unmodifiable map.
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

/// Synchronous, in-memory paginator.
///
/// Stores all items in a list and slices them according to [pageSize].
class Paginator<T> extends BasePaginator<T> {
  /// Creates a [Paginator] with the provided [items], optional [pageSize], and [config].
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

  /// Cache for storing transformed paginators to avoid redundant operations.
  ///
  /// Each entry contains a transformed [Paginator<T>] along with its creation timestamp.
  final Map<Object, _CacheEntry<Paginator<T>>> _transformCache = {};

  @override
  List<T> get currentPageItems {
    if (items.isEmpty) return const [];
    final total = totalItems;
    final totalPages =
        (total / pageSize).ceil().clamp(1, double.infinity).toInt();

    // If the current page exceeds totalPages, clamp it to totalPages.
    if (currentPage > totalPages) {
      goToPage(totalPages);
    }

    final startIndex = (currentPage - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, total);

    try {
      return items.sublist(startIndex, endIndex);
    } catch (e) {
      lastError = PaginationException('Error slicing items', originalError: e);
      throw lastError!;
    }
  }

  /// Total number of items available for pagination.
  int get totalItems => items.length;

  /// Total number of pages based on [totalItems] and [pageSize].
  int get totalPages => totalItems == 0 ? 1 : (totalItems / pageSize).ceil();

  @override
  bool get hasNextPage => currentPage < totalPages;

  @override
  bool nextPage() {
    if (hasNextPage) {
      goToPage(currentPage + 1);
      return true;
    }
    return false;
  }

  @override
  bool previousPage() {
    if (hasPreviousPage) {
      goToPage(currentPage - 1);
      return true;
    }
    return false;
  }

  /// Clears all cached transformations.
  void clearTransforms() {
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
    clearTransforms();
    super.dispose();
  }

  /// Creates a new [Paginator] by applying a transformation function to each item.
  ///
  /// The [transform] function is applied to each item, and a new paginator is returned
  /// with the transformed items.
  Paginator<R> map<R>(R Function(T) transform) {
    final transformedItems = items.map(transform).toList();
    return Paginator<R>(
      items: transformedItems,
      pageSize: pageSize,
      config: config,
    );
  }

  /// Filters the items based on a [predicate] and returns a new [Paginator].
  ///
  /// Optionally, a [cacheKey] can be provided to reuse cached filter results.
  Paginator<T> where(bool Function(T) predicate, {Object? cacheKey}) {
    final key = cacheKey ?? predicate.hashCode;
    final cacheEntry = _transformCache[key];
    if (cacheEntry != null) {
      final isExpired =
          DateTime.now().difference(cacheEntry.createdAt) > config.cacheTimeout;
      if (!isExpired) {
        // Return the cached paginator.
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
    return newPaginator;
  }

  /// Sorts the items based on a [compare] function and returns a new [Paginator].
  ///
  /// Optionally, a [cacheKey] can be provided to reuse cached sort results.
  Paginator<T> sort(int Function(T a, T b) compare, {Object? cacheKey}) {
    final key = cacheKey ?? compare.hashCode;
    final cacheEntry = _transformCache[key];
    if (cacheEntry != null) {
      final isExpired =
          DateTime.now().difference(cacheEntry.createdAt) > config.cacheTimeout;
      if (!isExpired) {
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

/// An asynchronous paginator that fetches pages using a provided fetch function.
///
/// Includes concurrency handling, caching, retry logic, and more.
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

  /// The function responsible for fetching a specific page.
  ///
  /// Example signature: `Future<List<T>> fetchPage(int pageNumber, int pageSize)`.
  final Future<List<T>> Function(int pageNumber, int pageSize) fetchPage;

  /// Optional function to fetch the total number of items from an external source (e.g., an API).
  ///
  /// Used for determining the availability of the next page precisely.
  final Future<int> Function()? totalItemsFetcher;

  /// Cache for storing fetched pages along with their timestamps.
  final Map<int, _CacheEntry<List<T>>> _pageCache = {};

  /// Tracks the loading state for each page.
  final Map<int, PageState> _pageStates = {};

  /// Stream controller for broadcasting page-state changes.
  final StreamController<Map<String, dynamic>> _stateController =
      StreamController.broadcast();

  /// If a fetch is in progress, it is stored here to allow cancellation or awaiting.
  CancelableOperation<List<T>>? _ongoingFetch;

  /// Broadcast stream of each page's state changes.
  ///
  /// Emits a map containing the page number and its new state.
  Stream<Map<String, dynamic>> get stateStream => _stateController.stream;

  /// Emits the state change for a specific [page].
  void _emitPageState(int page, PageState state) {
    _pageStates[page] = state;
    _stateController.add({
      'page': page,
      'state': state,
    });
  }

  /// Retrieves the current state of a given [page].
  ///
  /// Returns [PageState.initial] if the state is not explicitly set.
  PageState getPageState(int page) => _pageStates[page] ?? PageState.initial;

  @override
  Future<bool> get hasNextPage async {
    // If a total item count is known, use it to determine if there's a next page.
    if (totalItemsFetcher != null) {
      final total = await totalItemsFetcher!();
      return currentPage * pageSize < total;
    }
    // Otherwise, perform a "peek" by fetching one item from the next page.
    try {
      final peekItems = await fetchPage(currentPage + 1, 1);
      return peekItems.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<T>> get currentPageItems async {
    final page = currentPage;

    // Return cached data if available and not expired.
    final cacheEntry = _pageCache[page];
    if (cacheEntry != null) {
      final age = DateTime.now().difference(cacheEntry.createdAt);
      if (age < config.cacheTimeout) {
        return cacheEntry.data;
      } else {
        // Remove expired cache entry.
        _pageCache.remove(page);
      }
    }

    // Prevent concurrent fetches for the same page.
    if (getPageState(page) == PageState.loading) {
      throw PaginationException('Page $page is already loading');
    }

    // Optionally cancel any ongoing fetch if configured to do so.
    if (config.autoCancelFetches && _ongoingFetch != null) {
      await _ongoingFetch?.cancel();
      _ongoingFetch = null;
    }

    // Mark the page as loading.
    _emitPageState(page, PageState.loading);
    lastError = null;

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

        // Cache the fetched items.
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
          rethrow;
        }
        // Wait before retrying.
        await config.retryDelay.delayed<dynamic>();
      }
    }

    throw StateError('Unexpected: fell through retry loop');
  }

  @override
  Future<bool> nextPage() async {
    if (await hasNextPage) {
      goToPage(currentPage + 1);
      return true;
    }
    return false;
  }

  @override
  Future<bool> previousPage() async {
    if (hasPreviousPage) {
      goToPage(currentPage - 1);
      return true;
    }
    return false;
  }

  /// Clears all cached pages and resets page states.
  void clearCache() {
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
    _ongoingFetch?.cancel();
    _stateController.close();
    clearCache();
    super.dispose();
  }
}

/// A generic "cursor" used for cursor-based pagination.
///
/// Immutable to ensure the cursor value remains consistent.
@immutable
class PaginationCursor<T> {
  /// Creates a [PaginationCursor] with the provided [value].
  const PaginationCursor(this.value);

  /// The value representing the current position in pagination.
  final T value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PaginationCursor<T> && other.value == value);
  }

  @override
  int get hashCode => value.hashCode;
}

/// An infinite paginator that supports both page-based and cursor-based pagination.
///
/// Continuously loads more items until no more are available.
class InfinitePaginator<T, C> {
  /// Private constructor used by factory methods.
  InfinitePaginator._({
    required this.fetchItems,
    required this.updatePaginationKey,
    required this.pageSize,
    required this.initialKey,
    this.config = const PaginationConfig(),
  }) {
    _currentKey = initialKey;
  }

  /// Factory constructor for creating a page-based [InfinitePaginator].
  ///
  /// - [fetchItems]: Function to fetch items based on [pageSize] and [pageNumber].
  /// - [pageSize]: Number of items per fetch. Defaults to 20.
  /// - [initialPageNumber]: Starting page number. Defaults to 1.
  /// - [config]: Optional pagination configuration.
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

  /// Factory constructor for creating a cursor-based [InfinitePaginator].
  ///
  /// - [fetchItems]: Function to fetch items based on [pageSize] and a [PaginationCursor].
  /// - [getNextCursor]: Function to determine the next cursor from newly fetched items.
  /// - [pageSize]: Number of items per fetch. Defaults to 20.
  /// - [initialCursor]: Optional initial cursor. If not provided, defaults to `null`.
  /// - [config]: Optional pagination configuration.
  factory InfinitePaginator.cursorBased({
    required Future<List<T>> Function(int pageSize, PaginationCursor<C> cursor)
        fetchItems,
    required PaginationCursor<C> Function(List<T> newItems) getNextCursor,
    int pageSize = 20,
    PaginationCursor<C>? initialCursor,
    PaginationConfig? config,
  }) {
    return InfinitePaginator._(
      fetchItems: (size, key) => fetchItems(size, key as PaginationCursor<C>),
      updatePaginationKey: (items, oldKey) => getNextCursor(items),
      pageSize: pageSize,
      initialKey: initialCursor ?? PaginationCursor<C>(null as C),
      config: config ?? const PaginationConfig(),
    );
  }

  /// Internal list of all loaded items.
  final List<T> _items = [];

  /// Function to fetch items based on [pageSize] and a dynamic pagination key.
  final Future<List<T>> Function(int pageSize, dynamic paginationKey)
      fetchItems;

  /// Function to update the pagination key based on newly fetched [items] and the current [oldKey].
  final dynamic Function(List<T> items, dynamic currentKey) updatePaginationKey;

  /// Configuration for pagination behavior.
  final PaginationConfig config;

  /// Number of items to fetch per request.
  final int pageSize;

  /// The initial pagination key (page number or cursor).
  final dynamic initialKey;

  dynamic _currentKey;
  bool _isLoading = false;
  bool _hasMoreItems = true;

  /// lastError
  Exception? lastError;

  /// Stream controller to broadcast loading state changes.
  final StreamController<bool> _loadingController =
      StreamController<bool>.broadcast();

  /// If a fetch is in progress, it is stored here to allow cancellation or awaiting.
  CancelableOperation<List<T>>? _ongoingFetch;

  /// Stream that notifies listeners about loading state changes.
  ///
  /// Emits `true` when loading starts and `false` when loading ends.
  Stream<bool> get loadingStream => _loadingController.stream;

  /// Unmodifiable list of all loaded items.
  List<T> get items => List.unmodifiable(_items);

  /// Indicates whether a fetch operation is currently in progress.
  bool get isLoading => _isLoading;

  /// Indicates whether there are more items to load.
  bool get hasMoreItems => _hasMoreItems;

  /// Total number of items loaded so far.
  int get itemCount => _items.length;

  /// Loads more items into the paginator.
  ///
  /// Handles retry logic and updates the pagination key accordingly.
  Future<void> loadMoreItems() async {
    if (_isLoading || !_hasMoreItems) return;

    _isLoading = true;
    _loadingController.add(true);

    // Optionally cancel any ongoing fetch to prevent overlaps.
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
          // No more items to load.
          _hasMoreItems = false;
        } else {
          _items.addAll(newItems);
          // Update the pagination key for the next fetch.
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
        // Wait before retrying.
        await config.retryDelay.delayed<dynamic>();
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
  /// Clears all loaded items and resets pagination keys.
  void reset() {
    _items.clear();
    _hasMoreItems = true;
    _isLoading = false;
    _currentKey = initialKey;
    lastError = null;
    _loadingController.add(false);
  }

  /// Disposes of resources used by the paginator, such as ongoing fetches and streams.
  void dispose() {
    _ongoingFetch?.cancel();
    _loadingController.close();
    // Clear loaded items to free memory.
    _items.clear();
  }

  /// Provides the current state of the paginator for debugging or informational purposes.
  Map<String, dynamic> get state => {
        'itemCount': itemCount,
        'hasMoreItems': hasMoreItems,
        'isLoading': isLoading,
        'lastError': lastError?.toString(),
      };
}

/// Extension methods to transform fetched data in an [AsyncPaginator].
///
/// Note: If your filtering is expensive or the data set is large,
/// consider handling those transformations server-side if possible.
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
  /// This approach fetches double the [pageSize], applies the filter, and then takes the first [pageSize] items.
  /// For more comprehensive filtering, consider fetching additional pages until a full page of valid items is obtained.
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
  /// Throws a [StateError] if any validation fails.
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
