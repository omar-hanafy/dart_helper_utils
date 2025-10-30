import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('DoublyLinkedList', () {
    late DoublyLinkedList<int> list;

    setUp(() {
      list = DoublyLinkedList<int>();
    });

    test('should start with an empty list', () {
      expect(list.length, equals(0));
      expect(list.isEmpty, isTrue);
    });

    test('should insert into an empty list', () {
      list.insert(0, 1);
      expect(list.length, equals(1));
      expect(list.first, equals(1));
      expect(list.last, equals(1));
    });

    test('should remove from a list with one element', () {
      list
        ..add(1)
        ..removeAt(0);
      expect(list.length, equals(0));
      expect(list.isEmpty, isTrue);
      expect(list.head, isNull);
      expect(list.tail, isNull);
    });

    test('should append elements to the list', () {
      list
        ..add(1)
        ..add(2)
        ..add(3);

      expect(list.length, equals(3));
      expect(list.first, equals(1));
      expect(list.last, equals(3));
      expect(list[0], equals(1));
      expect(list[1], equals(2));
      expect(list[2], equals(3));
    });

    test('should prepend elements to the list', () {
      list
        ..prepend(1)
        ..prepend(2)
        ..prepend(3);

      expect(list.length, equals(3));
      expect(list.first, equals(3));
      expect(list.last, equals(1));
      expect(list[0], equals(3));
      expect(list[1], equals(2));
      expect(list[2], equals(1));
    });

    test('should insert elements at specific positions', () {
      list
        ..add(1)
        ..add(3)
        ..insert(1, 2);

      expect(list.length, equals(3));
      expect(list[0], equals(1));
      expect(list[1], equals(2));
      expect(list[2], equals(3));
    });

    test('should throw RangeError for negative indices', () {
      list.add(1);
      expect(() => list[-1], throwsA(isA<RangeError>()));
    });

    test('should throw RangeError for out-of-bounds indices', () {
      list.add(1);
      expect(() => list[1], throwsA(isA<RangeError>()));
    });

    test('should insert at beginning, end, and middle', () {
      list.insert(0, 1); // Insert at beginning
      expect(list.first, equals(1));

      list.insert(list.length, 2); // Insert at end
      expect(list.last, equals(2));

      list.insert(1, 3); // Insert in the middle
      expect(list[1], equals(3));
    });

    test('should throw RangeError for invalid insert index', () {
      expect(() => list.insert(-1, 1), throwsA(isA<RangeError>()));
      expect(
        () => list.insert(1, 1),
        throwsA(isA<RangeError>()),
      ); // List is empty
    });

    test('should remove elements by value', () {
      list
        ..add(1)
        ..add(2)
        ..add(3);

      expect(list.removeByValue(2), isTrue);
      expect(list.length, equals(2));
      expect(list.contains(2), isFalse);

      expect(list.removeByValue(4), isFalse);
      expect(list.length, equals(2));
    });

    test('should return false when removing non-existent value', () {
      list.add(1);
      expect(list.removeByValue(2), isFalse);
      expect(list.length, equals(1)); // List should not change
    });

    test('should remove elements by index', () {
      list
        ..add(1)
        ..add(2)
        ..add(3);

      expect(list.removeAt(1), equals(2));
      expect(list.length, equals(2));
      expect(list.contains(2), isFalse);
    });

    test('swapNodes updates head and tail for adjacent nodes', () {
      list
        ..add(1)
        ..add(2)
        ..add(3);

      final headNode = list.head!;
      final secondNode = headNode.next!;

      list.swapNodes(headNode, secondNode);

      expect(list.head, same(secondNode));
      expect(list.first, equals(2));
      expect(list[1], equals(1));
      expect(list.tail!.data, equals(3));

      final tailNode = list.tail!;
      final beforeTail = tailNode.prev!;

      list.swapNodes(beforeTail, tailNode);

      expect(list.tail, same(beforeTail));
      expect(list.last, equals(1));
      expect(list.toList(), equals([2, 3, 1]));
    });

    test('swapNodes swaps non-adjacent endpoints', () {
      list
        ..add(1)
        ..add(2)
        ..add(3)
        ..add(4);

      final headNode = list.head!;
      final tailNode = list.tail!;

      list.swapNodes(headNode, tailNode);

      expect(list.head!.data, equals(4));
      expect(list.tail!.data, equals(1));
      expect(list.toList(), equals([4, 2, 3, 1]));
    });

    test('should throw RangeError for invalid removeAt index', () {
      list.add(1);
      expect(() => list.removeAt(-1), throwsA(isA<RangeError>()));
      expect(() => list.removeAt(1), throwsA(isA<RangeError>()));
    });

    test('should clear the list', () {
      list
        ..add(1)
        ..add(2)
        ..add(3)
        ..clear();
      expect(list.length, equals(0));
      expect(list.isEmpty, isTrue);
    });

    test('should correctly find nodes or return null', () {
      list
        ..add(1)
        ..add(2)
        ..add(2)
        ..add(3);

      expect(list.findNodeByElement(2)!.data, equals(2)); // First '2'
      expect(list.findNodeByElement(5), isNull); // Non-existent
    });

    test('should handle empty list operations gracefully', () {
      expect(list.length, equals(0));
      expect(() => list.first, throwsA(isA<StateError>()));
      expect(() => list.last, throwsA(isA<StateError>()));
      expect(() => list.single, throwsA(isA<StateError>()));
    });

    test('should support iteration over elements', () {
      list
        ..add(1)
        ..add(2)
        ..add(3);

      final elements = <int>[];
      for (final element in list) {
        elements.add(element);
      }

      expect(elements, equals([1, 2, 3]));
    });

    test('should support index operations', () {
      list
        ..add(1)
        ..add(2)
        ..add(3);

      expect(list.indexOf(2), equals(1));
      expect(list.indexOf(4), equals(-1));
      expect(list.lastIndexOf(3), equals(2));
      expect(list.lastIndexOf(4), equals(-1));
    });

    test('should throw UnsupportedError when trying to set length', () {
      expect(() => list.length = 10, throwsA(isA<UnsupportedError>()));
    });

    test('can shrink length to zero', () {
      list
        ..add(1)
        ..add(2)
        ..length = 0;

      expect(list.length, equals(0));
      expect(list.head, isNull);
      expect(list.tail, isNull);
    });

    test('length shrink detaches truncated nodes', () {
      list
        ..add(1)
        ..add(2)
        ..add(3)
        ..add(4);

      final removedHead = list.findNode(2);

      list..length = 2;

      expect(list.toList(), equals([1, 2]));
      expect(removedHead.prev, isNull);
      expect(list.removeNode(removedHead), isFalse);
      expect(list.tail!.data, equals(2));
    });

    test('should support reverse iteration', () {
      list
        ..add(1)
        ..add(2)
        ..add(3);

      final elements = <int>[];
      var current = list.tail;
      while (current != null) {
        elements.add(current.data);
        current = current.prev;
      }

      expect(elements, equals([3, 2, 1]));
    });

    test('reverse updates head and tail for odd length list', () {
      list
        ..add(1)
        ..add(2)
        ..add(3);

      list.reverse();

      expect(list.toList(), equals([3, 2, 1]));
      expect(list.head!.data, equals(3));
      expect(list.tail!.data, equals(1));
    });

    test('toString should return correct string representation', () {
      list
        ..add(1)
        ..add(2)
        ..add(3);

      final elements = list.map((e) => e.toString()).join(' -> ');
      expect(elements, equals('1 -> 2 -> 3'));
    });

    test(
        'should throw RangeError for invalid removeAt index with clear message',
        () {
      list.add(1);
      expect(() => list.removeAt(-1), throwsRangeError);
      expect(() => list.removeAt(1), throwsRangeError);
    });

    test('removeNode ignores nodes from other lists', () {
      list
        ..add(1)
        ..add(2)
        ..add(3);

      final other = DoublyLinkedList<int>([4, 5]);

      expect(list.removeNode(other.head!), isFalse);
      expect(list.toList(), equals([1, 2, 3]));
    });

    test('constructor copies nodes instead of aliasing', () {
      final original = DoublyLinkedList<int>([1, 2, 3]);
      final copy = DoublyLinkedList<int>(original);

      expect(copy.toList(), equals([1, 2, 3]));

      copy.removeAt(0);

      expect(copy.toList(), equals([2, 3]));
      expect(original.toList(), equals([1, 2, 3]));
    });
  });
}
