// ignore_for_file: cascade_invocations
import 'dart:async';

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Base Paginator Tests', () {
    group('Configuration Tests', () {
      test('Initialization with valid page size', () {
        final paginator = Paginator<int>(items: [1, 2, 3], pageSize: 1);
        expect(paginator.pageSize, equals(1));
      });

      test('Initialization with invalid page size throws error', () {
        expect(
          () => Paginator<int>(items: [1, 2, 3], pageSize: 0),
          throwsArgumentError,
        );
      });

      test('Default configuration values', () {
        final paginator = Paginator<int>(items: [1, 2, 3]);
        expect(paginator.config.retryAttempts, equals(3));
        expect(paginator.config.retryDelay, equals(const Duration(seconds: 1)));
        expect(
          paginator.config.cacheTimeout,
          equals(const Duration(minutes: 5)),
        );
        expect(paginator.config.autoCancelFetches, isTrue);
        expect(paginator.config.maxCacheSize, equals(100));
      });

      test('Custom configuration values', () {
        const config = PaginationConfig(
          retryAttempts: 5,
          retryDelay: Duration(seconds: 2),
          cacheTimeout: Duration(minutes: 10),
          autoCancelFetches: false,
          maxCacheSize: 50,
        );
        final paginator = Paginator<int>(
          items: [1, 2, 3, 4, 5],
          pageSize: 2,
          config: config,
        );
        expect(paginator.config.retryAttempts, equals(5));
        expect(paginator.config.retryDelay, equals(const Duration(seconds: 2)));
        expect(
          paginator.config.cacheTimeout,
          equals(const Duration(minutes: 10)),
        );
        expect(paginator.config.autoCancelFetches, isFalse);
        expect(paginator.config.maxCacheSize, equals(50));
      });
    });

    group('Lifecycle Events', () {
      test('Emits event for page change', () async {
        final paginator = Paginator<int>(
          items: List.generate(20, (i) => i),
          pageSize: 5,
        );
        final events = <String>[];
        final sub = paginator.lifecycleStream.listen(events.add);
        paginator.goToPage(2);
        await Future<void>.delayed(Duration.zero);
        expect(events, contains('pageChanged'));
        await sub.cancel();
      });

      test('Emits event for reset', () async {
        final paginator = Paginator<int>(
          items: List.generate(10, (i) => i),
          pageSize: 2,
        );
        final events = <String>[];
        final sub = paginator.lifecycleStream.listen(events.add);
        paginator.reset();
        await Future<void>.delayed(Duration.zero);
        expect(events, contains('reset'));
        await sub.cancel();
      });

      test('Emits event for page size change', () async {
        final paginator = Paginator<int>(
          items: List.generate(10, (i) => i),
          pageSize: 2,
        );
        final events = <String>[];
        final sub = paginator.lifecycleStream.listen(events.add);
        paginator.pageSize = 3;
        await Future<void>.delayed(Duration.zero);
        expect(events, contains('pageSizeChanged'));
        await sub.cancel();
      });

      test('No events emitted after disposal', () async {
        final paginator = Paginator<int>(
          items: List.generate(10, (i) => i),
          pageSize: 2,
        );
        final events = <String>[];
        final sub = paginator.lifecycleStream.listen(events.add);
        paginator.dispose();
        paginator.goToPage(2);
        await Future<void>.delayed(Duration.zero);
        expect(events, isEmpty);
        await sub.cancel();
      });
    });

    group('Resource Management', () {
      test('Dispose cleans up timers and streams', () {
        final paginator = Paginator<int>(items: [1, 2, 3], pageSize: 1);
        paginator.goToPage(2);
        paginator.dispose();
        expect(paginator.dispose, returnsNormally);
      });
    });
  });

  group('Synchronous Paginator Tests', () {
    group('Basic Functionality', () {
      test('Initial state and basic navigation', () async {
        final items = List.generate(10, (i) => i);
        final paginator = Paginator<int>(items: items, pageSize: 3);
        expect(paginator.currentPage, equals(1));
        expect(paginator.currentPageItems, equals(items.sublist(0, 3)));
        paginator.nextPage();
        expect(paginator.currentPage, equals(2));
        expect(paginator.currentPageItems, equals(items.sublist(3, 6)));
      });

      test('Empty list handling', () {
        final paginator = Paginator<int>(items: [], pageSize: 3);
        expect(paginator.currentPageItems, equals([]));
      });

      test('Single page handling', () {
        final paginator = Paginator<int>(items: [1, 2], pageSize: 5);
        expect(paginator.currentPageItems, equals([1, 2]));
        expect(paginator.hasNextPage, isFalse);
        expect(paginator.hasPreviousPage, isFalse);
      });

      test('Multi-page handling and out-of-bound navigation', () async {
        final items = List.generate(10, (i) => i);
        final paginator = Paginator<int>(items: items, pageSize: 3);
        paginator.goToPage(4);
        expect(paginator.currentPage, equals(4));
        expect(paginator.currentPageItems, equals(items.sublist(9, 10)));
      });

      test('Invalid page navigation (negative page number)', () async {
        final items = List.generate(10, (i) => i);
        final paginator = Paginator<int>(items: items, pageSize: 3);
        paginator.goToPage(-5);
        expect(paginator.currentPage, equals(1));
      });
    });

    group('Transformation Tests', () {
      test('Map operation transforms items', () {
        final items = [1, 2, 3];
        final paginator = Paginator<int>(items: items, pageSize: 2);
        final mapped = paginator.map((x) => 'Item $x');
        expect(mapped.currentPageItems, equals(['Item 1', 'Item 2']));
      });

      test('Where operation filters items and caches results', () {
        final items = [1, 2, 3, 4, 5];
        final paginator = Paginator<int>(items: items, pageSize: 2);
        bool evenPredicate(int x) => x.isEven;
        final filtered1 = paginator.where(evenPredicate);
        final filtered2 = paginator.where(evenPredicate);
        // Check that the same instance is returned on a cache hit.
        expect(identical(filtered1, filtered2), isTrue);
        expect(paginator.metrics['cacheHits'], greaterThan(0));
      });

      test('Sort operation orders items', () {
        final items = [3, 1, 2];
        final paginator = Paginator<int>(items: items, pageSize: 3);
        final sorted = paginator.sort((a, b) => a.compareTo(b));
        expect(sorted.currentPageItems, equals([1, 2, 3]));
      });
    });

    group('Cache Management', () {
      test('Cache entry expiration', () async {
        const config = PaginationConfig(
          cacheTimeout: Duration(milliseconds: 100),
        );
        final paginator = Paginator<int>(
          items: [1, 2, 3, 4, 5],
          pageSize: 2,
          config: config,
        );
        final filtered = paginator.where((x) => x > 2);
        await 150.millisecondsDelay();
        final filtered2 = paginator.where((x) => x > 2);
        expect(identical(filtered, filtered2), isFalse);
      });

      test('Clear cache functionality', () {
        final paginator = Paginator<int>(items: [1, 2, 3, 4], pageSize: 2);
        paginator.where((x) => x.isEven);
        paginator.clearTransforms();
        expect(() => paginator.where((x) => x.isEven), returnsNormally);
      });
    });
  });

  group('Async Paginator Tests', () {
    group('Fetch Behavior', () {
      test('Basic fetch functionality', () async {
        // Dummy fetch function returning a list after a short delay.
        Future<List<int>> fetchPage(int pageNumber, int pageSize) async {
          await 50.millisecondsDelay();
          return List.generate(
            pageSize,
            (i) => (pageNumber - 1) * pageSize + i + 1,
          );
        }

        final asyncPaginator = AsyncPaginator<int>(
          fetchPage: fetchPage,
          pageSize: 3,
        );
        final items = await asyncPaginator.currentPageItems;
        expect(items, equals([1, 2, 3]));
      });

      test('Fetch deduplication', () async {
        var fetchCount = 0;
        Future<List<int>> fetchPage(int pageNumber, int pageSize) async {
          fetchCount++;
          await 50.millisecondsDelay();
          return List.generate(
            pageSize,
            (i) => (pageNumber - 1) * pageSize + i + 1,
          );
        }

        final asyncPaginator = AsyncPaginator<int>(
          fetchPage: fetchPage,
          pageSize: 3,
        );
        // Call currentPageItems twice concurrently.
        final results = await Future.wait([
          asyncPaginator.currentPageItems,
          asyncPaginator.currentPageItems,
        ]);
        expect(fetchCount, equals(1));
        expect(results[0], equals([1, 2, 3]));
        expect(results[1], equals([1, 2, 3]));
      });

      test('Exponential backoff and retry mechanism', () async {
        var attempt = 0;
        Future<List<int>> fetchPage(int pageNumber, int pageSize) async {
          attempt++;
          if (attempt < 3) throw Exception('Fetch error');
          return List.generate(
            pageSize,
            (i) => (pageNumber - 1) * pageSize + i + 1,
          );
        }

        const config = PaginationConfig(
          retryAttempts: 5,
          retryDelay: Duration(milliseconds: 10),
        );
        final asyncPaginator = AsyncPaginator<int>(
          fetchPage: fetchPage,
          pageSize: 2,
          config: config,
        );
        final items = await asyncPaginator.currentPageItems;
        expect(items, equals([1, 2]));
        expect(attempt, greaterThanOrEqualTo(3));
      });
    });

    group('Error Handling', () {
      test('Error state propagation', () async {
        Future<List<int>> fetchPage(int pageNumber, int pageSize) async {
          throw Exception('Fetch error');
        }

        final asyncPaginator = AsyncPaginator<int>(
          fetchPage: fetchPage,
          pageSize: 2,
        );
        expect(
          () async => asyncPaginator.currentPageItems,
          throwsA(isA<PaginationException>()),
        );
      });
    });

    group('Cache Management', () {
      test('Page caching', () async {
        var fetchCount = 0;
        Future<List<int>> fetchPage(int pageNumber, int pageSize) async {
          fetchCount++;
          await 50.millisecondsDelay();
          return List.generate(pageSize, (i) => i + 1);
        }

        final asyncPaginator = AsyncPaginator<int>(
          fetchPage: fetchPage,
          pageSize: 2,
        );
        final items1 = await asyncPaginator.currentPageItems;
        final items2 = await asyncPaginator.currentPageItems;
        expect(fetchCount, equals(1));
        expect(items1, equals(items2));
      });

      test('Cache invalidation after timeout', () async {
        const config = PaginationConfig(
          cacheTimeout: Duration(milliseconds: 100),
        );
        var fetchCount = 0;
        Future<List<int>> fetchPage(int pageNumber, int pageSize) async {
          fetchCount++;
          await 50.millisecondsDelay();
          return List.generate(pageSize, (i) => i + 1);
        }

        final asyncPaginator = AsyncPaginator<int>(
          fetchPage: fetchPage,
          pageSize: 2,
          config: config,
        );
        await asyncPaginator.currentPageItems;
        await 150.millisecondsDelay();
        await asyncPaginator.currentPageItems;
        expect(fetchCount, equals(2));
      });
    });

    group('State Management', () {
      test('Loading state transitions', () async {
        final completer = Completer<List<int>>();
        Future<List<int>> fetchPage(int pageNumber, int pageSize) async {
          return completer.future;
        }

        final asyncPaginator = AsyncPaginator<int>(
          fetchPage: fetchPage,
          pageSize: 2,
        );

        // Start fetching without awaiting immediately.
        final future = asyncPaginator.currentPageItems;

        // Check that the paginator is in loading state.
        expect(asyncPaginator.isLoading, isTrue);

        // Complete the fetch.
        completer.complete([1, 2]);

        // Await the result.
        final items = await future;
        expect(items, equals([1, 2]));

        // After a short delay, confirm that loading is finished.
        await 60.millisecondsDelay();
        expect(asyncPaginator.isLoading, isFalse);
      });
    });
  });

  group('Infinite Paginator Tests', () {
    group('Page-Based Tests', () {
      test('Initial load and continuous loading', () async {
        Future<List<int>> fetchItems(int pageSize, int pageNumber) async {
          await 30.millisecondsDelay();
          if (pageNumber > 3) return [];
          return List.generate(
            pageSize,
            (i) => (pageNumber - 1) * pageSize + i + 1,
          );
        }

        final infinitePaginator = InfinitePaginator<int, int>.pageBased(
          fetchItems: fetchItems,
          pageSize: 3,
        );
        await infinitePaginator.loadMoreItems();
        expect(infinitePaginator.items.length, equals(3));
        await infinitePaginator.loadMoreItems();
        expect(infinitePaginator.items.length, equals(6));
        await infinitePaginator.loadMoreItems();
        expect(infinitePaginator.items.length, equals(9));
        await infinitePaginator.loadMoreItems();
        // No more items should be loaded.
        expect(infinitePaginator.items.length, equals(9));
      });

      test('Reset functionality', () async {
        Future<List<int>> fetchItems(int pageSize, int pageNumber) async {
          await 30.millisecondsDelay();
          if (pageNumber > 2) return [];
          return List.generate(
            pageSize,
            (i) => (pageNumber - 1) * pageSize + i + 1,
          );
        }

        final infinitePaginator = InfinitePaginator<int, int>.pageBased(
          fetchItems: fetchItems,
          pageSize: 2,
        );
        await infinitePaginator.loadMoreItems();
        expect(infinitePaginator.items.length, equals(2));
        infinitePaginator.reset();
        expect(infinitePaginator.items, isEmpty);
      });
    });

    group('Cursor-Based Tests', () {
      test('Cursor initialization and updates', () async {
        // Dummy cursor-based fetch.
        Future<List<int>> fetchItems(
          int pageSize,
          PaginationCursor<int> cursor,
        ) async {
          await 30.millisecondsDelay();
          if (cursor.value > 3) return [];
          return List.generate(pageSize, (i) => cursor.value * pageSize + i);
        }

        PaginationCursor<int> getNextCursor(List<int> items) {
          return PaginationCursor<int>(
            items.isNotEmpty ? (items.first ~/ 10) + 1 : 4,
          );
        }

        final infinitePaginator = InfinitePaginator<int, int>.cursorBased(
          fetchItems: fetchItems,
          getNextCursor: getNextCursor,
          pageSize: 2,
        );
        await infinitePaginator.loadMoreItems();
        expect(infinitePaginator.items.length, equals(2));
        await infinitePaginator.loadMoreItems();
        expect(infinitePaginator.items.length, equals(4));
      });
    });
  });

  group('Analytics Tests', () {
    test('Metrics tracking for synchronous paginator', () {
      final items = [1, 2, 3, 4, 5];
      final paginator = Paginator<int>(items: items, pageSize: 2);
      // Simulate a cache hit by calling a where transformation twice.
      bool isGreaterThanTwo(int x) => x > 2;
      paginator.where(isGreaterThanTwo);
      paginator.where(isGreaterThanTwo);
      expect(paginator.metrics['cacheHits'], greaterThan(0));
    });
  });
}
