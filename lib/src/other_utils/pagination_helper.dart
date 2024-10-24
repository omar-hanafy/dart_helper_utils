import 'dart:async';

/// Base interface for paginator
abstract class IPaginator<T> {
  /// The number of items per page.
  int get pageSize;

  set pageSize(int size);

  /// The current page number.
  int get currentPage;

  /// Navigates to the specified page number.
  void goToPage(int pageNumber);

  /// Resets the paginator to the initial state.
  void reset();
}

/// Synchronous Paginator for in-memory lists
class Paginator<T> implements IPaginator<T> {
  /// Creates a [Paginator] with the given [items] and optional [pageSize].
  Paginator({
    required this.items,
    int pageSize = 10,
  }) : _pageSize = pageSize;

  /// The list of items to paginate.
  final List<T> items;

  int _pageSize;

  @override
  int get pageSize => _pageSize;

  @override
  set pageSize(int size) {
    if (size <= 0) {
      throw ArgumentError('Page size must be greater than zero');
    }
    final currentItemIndex = (_currentPage - 1) * _pageSize;
    _pageSize = size;
    _currentPage = (currentItemIndex / _pageSize).floor() + 1;
  }

  int _currentPage = 1;

  /// The total number of items.
  int get totalItems => items.length;

  /// The total number of pages.
  int get totalPages => totalItems == 0 ? 1 : (totalItems / pageSize).ceil();

  @override
  int get currentPage => _currentPage;

  /// The items on the current page.
  List<T> get currentPageItems {
    if (totalItems == 0) return [];
    final startIndex = (_currentPage - 1) * pageSize;
    var endIndex = startIndex + pageSize;
    endIndex = endIndex > totalItems ? totalItems : endIndex;
    return items.sublist(startIndex, endIndex);
  }

  /// Advances to the next page if possible.
  bool nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      return true;
    }
    return false;
  }

  /// Moves to the previous page if possible.
  bool previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      return true;
    }
    return false;
  }

  /// Whether there is a next page.
  bool get hasNextPage => _currentPage < totalPages;

  /// Whether there is a previous page.
  bool get hasPreviousPage => _currentPage > 1;

  @override
  void goToPage(int pageNumber) {
    if (pageNumber < 1 || pageNumber > totalPages) {
      throw RangeError('Page number out of range');
    }
    _currentPage = pageNumber;
  }

  /// Goes to the first page.
  void goToFirstPage() {
    _currentPage = 1;
  }

  /// Goes to the last page.
  void goToLastPage() {
    _currentPage = totalPages;
  }

  @override
  void reset() {
    _currentPage = 1;
  }

  /// Applies a filter and returns a new [Paginator] instance.
  Paginator<T> filter(bool Function(T) predicate) {
    final filteredItems = items.where(predicate).toList();
    return Paginator<T>(items: filteredItems, pageSize: pageSize);
  }

  /// Sorts items and returns a new [Paginator] instance.
  Paginator<T> sorted(int Function(T a, T b) compare) {
    final sortedItems = List<T>.from(items)..sort(compare);
    return Paginator<T>(items: sortedItems, pageSize: pageSize);
  }

  /// Provides page information.
  Map<String, dynamic> get pageInfo => {
        'currentPage': _currentPage,
        'totalPages': totalPages,
        'pageSize': pageSize,
        'totalItems': totalItems,
        'hasNextPage': hasNextPage,
        'hasPreviousPage': hasPreviousPage,
        'isFirstPage': _currentPage == 1,
        'isLastPage': _currentPage == totalPages,
        'startIndex': totalItems == 0 ? 0 : (_currentPage - 1) * pageSize + 1,
        'endIndex': totalItems == 0
            ? 0
            : ((_currentPage * pageSize) > totalItems
                ? totalItems
                : _currentPage * pageSize),
      };
}

/// Asynchronous Paginator for data fetched from remote sources
class AsyncPaginator<T> implements IPaginator<T> {
  /// Creates an [AsyncPaginator] with the given [fetchPage] function and optional [pageSize].
  AsyncPaginator({
    required this.fetchPage,
    int pageSize = 10,
  }) : _pageSize = pageSize;

  /// Function to fetch items for a specific page.
  final Future<List<T>> Function(int pageNumber, int pageSize) fetchPage;

  int _pageSize;

  @override
  int get pageSize => _pageSize;

  @override
  set pageSize(int size) {
    if (size <= 0) {
      throw ArgumentError('Page size must be greater than zero');
    }
    _pageSize = size;
    _currentPage = 1;
  }

  int _currentPage = 1;

  @override
  int get currentPage => _currentPage;

  /// Fetches items for the current page.
  Future<List<T>> get currentPageItems => fetchPage(_currentPage, pageSize);

  @override
  void goToPage(int pageNumber) {
    if (pageNumber < 1) {
      throw RangeError('Page number must be at least 1');
    }
    _currentPage = pageNumber;
  }

  /// Advances to the next page if possible.
  Future<bool> nextPage() async {
    try {
      final items = await fetchPage(_currentPage + 1, pageSize);
      if (items.isEmpty) {
        return false;
      } else {
        _currentPage++;
        return true;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Moves to the previous page if possible.
  Future<bool> previousPage() async {
    if (_currentPage > 1) {
      _currentPage--;
      return true;
    }
    return false;
  }

  /// Whether there is a next page. Cannot be determined in advance; returns `null`.
  bool? get hasNextPage => null;

  /// Whether there is a previous page.
  bool get hasPreviousPage => _currentPage > 1;

  @override
  void reset() {
    _currentPage = 1;
  }
}

/// A generic class that provides infinite scrolling pagination functionality.
///
/// The `InfinitePaginator<T>` class abstracts the complexities of infinite
/// scrolling pagination, supporting both page-based and cursor-based strategies.
/// It is designed to be flexible and can be used to paginate any type of data.
///
/// **Key Features:**
/// - Supports both page-based and cursor-based pagination.
/// - Generic implementation for flexibility with different data types.
/// - Manages pagination state, including items list, loading state, and pagination key.
class InfinitePaginator<T> {
  /// Private constructor used by factory constructors.
  InfinitePaginator._({
    required this.fetchItems,
    required this.updatePaginationKey,
    required this.pageSize,
    required this.initialPaginationKey,
  }) {
    _paginationKey = initialPaginationKey;
  }

  /// Factory constructor for page-based pagination.
  ///
  /// Creates an `InfinitePaginator` configured for page-based pagination.
  ///
  /// - [fetchItems]: Function that fetches a list of items based on the
  ///   [pageSize] and [pageNumber].
  /// - [pageSize]: The number of items to fetch per request. Defaults to 20.
  /// - [initialPageNumber]: The starting page number. Defaults to 1.
  factory InfinitePaginator.pageBased({
    required Future<List<T>> Function(int pageSize, int pageNumber) fetchItems,
    int pageSize = 20,
    int initialPageNumber = 1,
  }) {
    return InfinitePaginator._(
      fetchItems: (pageSize, paginationKey) =>
          fetchItems(pageSize, paginationKey as int),
      updatePaginationKey: (items, currentPaginationKey) =>
          (currentPaginationKey as int) + 1,
      pageSize: pageSize,
      initialPaginationKey: initialPageNumber,
    );
  }

  /// Factory constructor for cursor-based pagination.
  ///
  /// Creates an `InfinitePaginator` configured for cursor-based pagination.
  ///
  /// - [fetchItems]: Function that fetches a list of items based on the
  ///   [pageSize] and [cursor].
  /// - [getNextCursor]: Function that computes the next cursor based on the
  ///   fetched [items].
  /// - [pageSize]: The number of items to fetch per request. Defaults to 20.
  /// - [initialCursor]: The initial cursor value. Can be `null`.
  factory InfinitePaginator.cursorBased({
    required Future<List<T>> Function(int pageSize, dynamic cursor) fetchItems,
    required dynamic Function(List<T> items) getNextCursor,
    int pageSize = 20,
    dynamic initialCursor,
  }) {
    return InfinitePaginator._(
      fetchItems: fetchItems,
      updatePaginationKey: (items, currentPaginationKey) =>
          getNextCursor(items),
      pageSize: pageSize,
      initialPaginationKey: initialCursor,
    );
  }

  /// A private list to store the fetched items.
  final List<T> _items = [];

  /// Indicates whether there are more items to load.
  bool _hasMoreItems = true;

  /// Tracks the loading state to prevent concurrent fetch operations.
  bool _isLoading = false;

  /// The current pagination key, which is dynamically updated.
  dynamic _paginationKey;

  /// Function that fetches items based on [pageSize] and [paginationKey].
  ///
  /// This function is provided during instantiation and is responsible for
  /// fetching the data from the data source (e.g., an API).
  final Future<List<T>> Function(int pageSize, dynamic paginationKey)
      fetchItems;

  /// Function that updates the [paginationKey] for the next fetch operation.
  ///
  /// - For page-based pagination, it typically increments the page number.
  /// - For cursor-based pagination, it extracts the next cursor from the
  ///   fetched items.
  final dynamic Function(List<T> items, dynamic currentPaginationKey)
      updatePaginationKey;

  /// The number of items to fetch per request.
  final int pageSize;

  /// The starting value for the pagination key.
  ///
  /// - For page-based pagination, this could be the initial page number.
  /// - For cursor-based pagination, this could be the initial cursor value.
  final dynamic initialPaginationKey;

  /// Fetches the next batch of items and updates the state accordingly.
  ///
  /// If there are no more items to load or a fetch operation is already in
  /// progress, the method returns immediately.
  ///
  /// This method should be called to load more items when the user scrolls
  /// to the bottom of the list.
  Future<void> loadMoreItems() async {
    if (_isLoading || !_hasMoreItems) return;

    _isLoading = true;
    try {
      final newItems = await fetchItems(pageSize, _paginationKey);
      if (newItems.isEmpty) {
        _hasMoreItems = false;
      } else {
        _items.addAll(newItems);
        _paginationKey = updatePaginationKey(newItems, _paginationKey);
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Resets the paginator to its initial state.
  ///
  /// This method clears all fetched items, resets the pagination key to its
  /// initial value, and sets the loading and availability states accordingly.
  void reset() {
    _items.clear();
    _hasMoreItems = true;
    _paginationKey = initialPaginationKey;
  }

  /// Provides read-only access to the fetched items.
  ///
  /// Returns an unmodifiable list of items that have been fetched so far.
  List<T> get items => List.unmodifiable(_items);

  /// Indicates whether there are more items available to load.
  bool get hasMoreItems => _hasMoreItems;
}
