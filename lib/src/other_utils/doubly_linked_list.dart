import 'dart:collection';

/// A node in a doubly linked list.
///
/// Each node contains data and references to the next and previous nodes in the list.
final class Node<E> {
  /// Creates a node with the given data.
  ///
  /// The node may also contain optional references to the next and previous nodes in the list.
  Node._(this.data, {this.next, this.prev});

  /// The data stored in this node.
  E data;

  /// The next node in the list.
  Node<E>? next;

  /// The previous node in the list.
  Node<E>? prev;

  @override
  String toString() => data.toString();
}

/// A doubly linked list implementation in Dart.
class DoublyLinkedList<E> extends ListBase<E> {
  /// Default constructor for a potentially empty list.
  ///
  /// ```dart
  /// final list = DoublyLinkedList<int>([1, 2, 3]);
  /// print(list); // Output: [1, 2, 3]
  /// ```
  DoublyLinkedList([Iterable<E>? elements = const []]) {
    if (elements != null && elements.isNotEmpty) {
      if (elements is DoublyLinkedList<E>) {
        _head = elements._head;
        _tail = elements._tail;
        _length = elements._length;
      } else {
        addAll(elements);
      }
    }
  }

  /// Creates a list of the given length with [fill] at each position.
  ///
  /// ```dart
  /// final list = DoublyLinkedList.filled(3, 0);
  /// print(list); // Output: [0, 0, 0]
  /// ```
  factory DoublyLinkedList.filled(int length, E fill) =>
      DoublyLinkedList(List.filled(length, fill));

  /// Generates a list of values using the provided generator function.
  ///
  /// ```dart
  /// final list = DoublyLinkedList.generate(3, (index) => index * 2);
  /// print(list); // Output: [0, 2, 4]
  /// ```
  factory DoublyLinkedList.generate(
    int length,
    E Function(int index) generator,
  ) {
    if (length < 0) {
      throw ArgumentError.value(length, 'length', 'must be non-negative');
    } // Proper error handling for negative length
    return DoublyLinkedList(List.generate(length, generator));
  }

  Node<E>? _head;

  Node<E>? _tail;

  int _length = 0;

  /// The last node in the list.
  Node<E>? get tail => _tail;

  /// The first node in the list.
  Node<E>? get head => _head;

  /// Appends a new node with the given data to the end of the list.
  ///
  /// ```dart
  /// final list = DoublyLinkedList<int>();
  /// list.append(1);
  /// list.append(2);
  /// print(list); // Output: [1, 2]
  /// ```
  void append(E data) {
    final newNode = Node._(data);
    if (_head == null) {
      _head = newNode;
      _tail = newNode;
    } else {
      _tail!.next = newNode;
      newNode.prev = _tail;
      _tail = newNode;
    }
    _length++;
  }

  /// Prepends a new node with the given data to the start of the list.
  ///
  /// ```dart
  /// final list = DoublyLinkedList<int>();
  /// list.prepend(2);
  /// list.prepend(1);
  /// print(list); // Output: [1, 2]
  /// ```
  void prepend(E data) {
    final newNode = Node._(data);
    if (_head == null) {
      _head = newNode;
      _tail = newNode;
    } else {
      _head!.prev = newNode;
      newNode.next = _head;
      _head = newNode;
    }
    _length++;
  }

  /// Removes the specified node from the list.
  ///
  /// ```dart
  /// final list = DoublyLinkedList<int>([1, 2, 3]);
  /// final node = list.findNodeByElement(2);
  /// list.removeNode(node!);
  /// print(list); // Output: [1, 3]
  /// ```
  bool removeNode(Node<E> node) {
    if (node == _head) {
      _head = node.next;
      if (_head != null) {
        _head!.prev = null;
      } else {
        // If removing the head from a single-node list, update tail
        _tail = null;
      }
    } else if (node == _tail) {
      _tail = node.prev;
      _tail?.next = null;
    } else if (node.prev != null && node.next != null) {
      node.prev!.next = node.next;
      node.next!.prev = node.prev;
    } else {
      return false; // Node not in the list or it's an isolated node
    }

    // Dereference the removed node to help with garbage collection
    node
      ..prev = null
      ..next = null;

    _length--;
    return true;
  }

  /// Removes the first node with the given value.
  ///
  /// ```dart
  /// final list = DoublyLinkedList<int>([1, 2, 3]);
  /// list.removeByValue(2);
  /// print(list); // Output: [1, 3]
  /// ```
  bool removeByValue(E value) {
    var current = _head;
    while (current != null) {
      if (current.data == value) {
        removeNode(current);
        return true;
      }
      current = current.next;
    }
    return false;
  }

  /// Finds the first node with the given data.
  ///
  /// ```dart
  /// final list = DoublyLinkedList<int>([1, 2, 3]);
  /// final node = list.findNodeByElement(2);
  /// print(node?.data); // Output: 2
  /// ```
  Node<E>? findNodeByElement(E data, {Node<E> Function()? orElse}) {
    var current = _head;
    while (current != null) {
      if (current.data == data) {
        return current;
      }
      current = current.next;
    }
    return orElse?.call();
  }

  /// Inserts a new node after the specified node.
  ///
  /// ```dart
  /// final list = DoublyLinkedList<int>([1, 3]);
  /// final node = list.findNodeByElement(1);
  /// list.insertAfter(node!, 2);
  /// print(list); // Output: [1, 2, 3]
  /// ```
  void insertAfter(Node<E> node, E data) {
    if (node == _tail) {
      append(data);
      return;
    }
    final newNode = Node._(data, next: node.next, prev: node);
    node.next?.prev = newNode;
    node.next = newNode;
    _length++;
  }

  /// Inserts a new node before the specified node.
  ///
  /// ```dart
  /// final list = DoublyLinkedList<int>([2, 3]);
  /// final node = list.findNodeByElement(2);
  /// list.insertBefore(node!, 1);
  /// print(list); // Output: [1, 2, 3]
  /// ```
  void insertBefore(Node<E> node, E data) {
    if (node == _head) {
      prepend(data);
      return;
    }
    final newNode = Node._(data, next: node, prev: node.prev);
    node.prev?.next = newNode;
    node.prev = newNode;
    _length++;
  }

  /// Returns an iterable of all nodes in the list.
  ///
  /// ```dart
  /// final list = DoublyLinkedList<int>([1, 2, 3]);
  /// for (var node in list.nodes) {
  ///   print(node.data); // Output: 1, 2, 3
  /// }
  /// ```
  Iterable<Node<E>> get nodes sync* {
    var current = _head;
    while (current != null) {
      yield current;
      current = current.next;
    }
  }

  /// Finds a node by its index.
  ///
  /// ```dart
  /// final list = DoublyLinkedList<int>([1, 2, 3]);
  /// final node = list.findNode(1);
  /// print(node?.data); // Output: 2
  /// ```
  Node<E> findNode(int index) => this ^ index;

  /// Finds a node by its index and returns null with RangeError.
  Node<E>? tryFindNode(int index) {
    try {
      return findNode(index);
    } catch (_) {}
    return null;
  }

  /// Operator to get a node by its index.
  ///
  /// ```dart
  /// final list = DoublyLinkedList<int>([1, 2, 3]);
  /// final node = list ^ 1;
  /// print(node?.data); // Output: 2
  /// ```
  Node<E> operator ^(int index) {
    if (index < 0 || index >= _length) throw RangeError.index(index, this);
    var current = _head;
    for (var i = 0; i < index; i++) {
      current = current!.next;
    }
    return current!;
  }

  /// Returns all nodes that satisfy the given test.
  Iterable<Node<E>> nodesWhere(bool Function(Node<E>) test) {
    final result = <Node<E>>[];
    for (final node in nodes) {
      if (test(node)) result.add(node);
    }
    return result;
  }

  /// Returns the first node that satisfies the given test.
  Node<E> firstNodeWhere(
    bool Function(Node<E>) test, {
    Node<E> Function()? orElse,
  }) {
    for (final node in nodes) {
      if (test(node)) return node;
    }
    final orElseData = orElse?.call();
    if (orElseData != null) return orElseData;
    throw StateError('No node found matching the predicate');
  }

  /// Returns the first node that satisfies the given test, or null if none found.
  Node<E>? firstNodeWhereOrNull(
    bool Function(Node<E>) test, {
    Node<E> Function()? orElse,
  }) {
    for (final node in nodes) {
      if (test(node)) return node;
    }
    return orElse?.call();
  }

  /// Returns the last node that satisfies the given test.
  Node<E> lastNodeWhere(
    bool Function(Node<E>) test, {
    Node<E> Function()? orElse,
  }) {
    for (var node = _tail; node != null; node = node.prev) {
      if (test(node)) return node;
    }
    final orElseData = orElse?.call();
    if (orElseData != null) return orElseData;
    throw StateError('No node found matching the predicate');
  }

  /// Returns the last node that satisfies the given test, or null if none found.
  Node<E>? lastNodeWhereOrNull(
    bool Function(Node<E>) test, {
    Node<E> Function()? orElse,
  }) {
    for (var node = _tail; node != null; node = node.prev) {
      if (test(node)) return node;
    }
    return orElse?.call();
  }

  /// Returns a single node that satisfies the given test.
  Node<E> singleNodeWhere(
    bool Function(Node<E>) test, {
    Node<E> Function()? orElse,
  }) {
    Node<E>? foundNode;
    for (final node in nodes) {
      if (test(node)) {
        if (foundNode != null) {
          throw StateError('More than one node found matching the predicate');
        }
        foundNode = node;
      }
    }
    if (foundNode == null) {
      final orElseData = orElse?.call();
      if (orElseData != null) return orElseData;
      throw StateError('No node found matching the predicate');
    }
    return foundNode;
  }

  /// same as [singleNodeWhere] but returns null when not found.
  Node<E>? singleNodeWhereOrNull(
    bool Function(Node<E>) test, {
    Node<E> Function()? orElse,
  }) {
    Node<E>? foundElement;
    for (final node in nodes) {
      if (test(node)) {
        if (foundElement != null) return null;
        foundElement = node;
      }
    }
    if (foundElement != null) return foundElement;
    return orElse?.call();
  }

  /// Replaces the data of the specified node with newData.
  void replaceNode(Node<E> node, E newData) {
    node.data = newData;
  }

  /// Removes all nodes whose data satisfies the test function.
  void removeNodesWhere(bool Function(E) test) {
    var current = _head;
    while (current != null) {
      final next = current.next;
      if (test(current.data)) removeNode(current);
      current = next;
    }
  }

// Swapping and Reversing
  /// Swaps the positions of two nodes in the list.
  void swapNodes(Node<E> node1, Node<E> node2) {
    assert(node1 != node2, 'Cannot swap the same node');

    // Handle special case where nodes are adjacent
    if (node1.next == node2) {
      _swapAdjacentNodes(node1, node2);
      return;
    } else if (node2.next == node1) {
      _swapAdjacentNodes(node2, node1);
      return;
    }

    // General case: Nodes are not adjacent
    _swapNonAdjacentNodes(node1, node2);

    // Update head and tail if necessary
    if (_head == node1) {
      _head = node2;
    } else if (_head == node2) {
      _head = node1;
    }
    if (_tail == node1) {
      _tail = node2;
    } else if (_tail == node2) {
      _tail = node1;
    }
  }

  void _swapAdjacentNodes(Node<E> first, Node<E> second) {
    final prev = first.prev;
    final next = second.next;

    if (prev != null) prev.next = second;
    if (next != null) next.prev = first;

    first
      ..next = next
      ..prev = second;
    second
      ..next = first
      ..prev = prev;
  }

  void _swapNonAdjacentNodes(Node<E> node1, Node<E> node2) {
    final tempPrev = node1.prev;
    final tempNext = node1.next;

    node1
      ..prev = node2.prev
      ..next = node2.next;
    node2
      ..prev = tempPrev
      ..next = tempNext;

    if (node1.prev != null) node1.prev!.next = node1;
    if (node1.next != null) node1.next!.prev = node1;
    if (node2.prev != null) node2.prev!.next = node2;
    if (node2.next != null) node2.next!.prev = node2;
  }

  /// Reverses the order of the nodes in the list.
  void reverse() {
    var current = _head;
    while (current != null) {
      final temp = current.next;
      current
        ..next = current.prev
        ..prev = temp;
      _tail = _head;
      _head = current;
      current = temp;
    }
  }

  /// Appends a new node with the given data to the end of the list.
  @override
  void add(E element) => append(element);

  /// please see the original docs of the override method
  @override
  Iterator<E> get iterator => _DoublyLinkedListIterator<E>(_head);

  /// please see the original docs of the override method
  @override
  int get length => _length;

  /// Sets the length of the doubly linked list to [newLength].
  ///
  /// If [newLength] is less than the current length, the list is truncated.
  /// If [newLength] is greater than the current length, an [UnsupportedError]
  /// is thrown as null elements cannot be appended to the list.
  ///
  /// ```dart
  /// final list = DoublyLinkedList([1, 2, 3]);
  /// list.length = 5; // Throws UnsupportedError
  /// list.length = 2; // List becomes [1, 2]
  /// ```
  @override
  set length(int newLength) {
    if (newLength < 0) {
      throw ArgumentError.value(newLength, 'newLength', 'cannot be negative');
    }

    if (newLength == _length) return;

    if (newLength < _length) {
      // Shrink the list
      var current = _tail;
      for (var i = _length; i > newLength; i--) {
        current = current!.prev;
      }

      current!.next = null; // Disconnect remaining nodes
      _tail = current;
    } else {
      // Grow the list (not supported for null elements)
      throw UnsupportedError(
        'Cannot increase length of DoublyLinkedList with null elements.',
      );
    }

    _length = newLength;
  }

  /// please see the original docs of the override method
  @override
  E operator [](int index) {
    if (index < 0 || index >= _length) throw RangeError.index(index, this);
    var current = _head;
    for (var i = 0; i < index; i++) {
      current = current!.next;
    }
    return current!.data;
  }

  /// please see the original docs of the override method
  @override
  void operator []=(int index, E value) {
    if (index < 0 || index >= _length) throw RangeError.index(index, this);
    var current = _head;
    for (var i = 0; i < index; i++) {
      current = current!.next;
    }
    current!.data = value;
  }

  /// please see the original docs of the override method
  @override
  bool remove(Object? element) {
    if (element is E) {
      return removeByValue(element);
    }
    return false;
  }

  /// please see the original docs of the override method
  @override
  void clear() {
    _head = null;
    _tail = null;
    _length = 0;
  }

  /// please see the original docs of the override method
  @override
  void insert(int index, E element) {
    if (index < 0 || index > _length) throw RangeError.index(index, this);
    if (index == 0) {
      prepend(element);
    } else if (index == _length) {
      append(element);
    } else {
      var current = _head;
      for (var i = 0; i < index; i++) {
        current = current!.next;
      }
      insertBefore(current!, element);
    }
  }

  /// please see the original docs of the override method
  @override
  E removeAt(int index) {
    if (index < 0 || index >= _length) throw RangeError.index(index, this);
    var current = _head;
    for (var i = 0; i < index; i++) {
      current = current!.next;
    }
    final data = current!.data;
    removeNode(current);
    return data;
  }

  /// please see the original docs of the override method
  @override
  E get first {
    if (_length == 0) throw StateError('No elements');
    return _head!.data;
  }

  /// please see the original docs of the override method
  @override
  E get last {
    if (_length == 0) throw StateError('No elements');
    return _tail!.data;
  }

  /// please see the original docs of the override method
  @override
  E get single {
    if (_length != 1) throw StateError('Not a single element');
    return _head!.data;
  }

  /// please see the original docs of the override method
  @override
  bool contains(Object? element) {
    if (element is E) {
      return findNodeByElement(element) != null;
    }
    return false;
  }

  /// please see the original docs of the override method
  @override
  int indexOf(Object? element, [int start = 0]) {
    var index = 0;
    var current = _head;
    while (current != null) {
      if (index >= start && current.data == element) {
        return index;
      }
      current = current.next;
      index++;
    }
    return -1;
  }

  /// please see the original docs of the override method
  @override
  int lastIndexOf(Object? element, [int? start]) {
    var index = _length - 1;
    var current = _tail;
    while (current != null) {
      if (start == null || index <= start) {
        if (current.data == element) {
          return index;
        }
      }
      current = current.prev;
      index--;
    }
    return -1;
  }
}

class _DoublyLinkedListIterator<E> implements Iterator<E> {
  _DoublyLinkedListIterator(Node<E>? head) {
    _current = head;
  }

  Node<E>? _current;
  bool _isFirst = true;

  /// please see the original docs of the override method
  @override
  E get current => _current!.data;

  /// please see the original docs of the override method
  @override
  bool moveNext() {
    if (_isFirst) {
      _isFirst = false;
      return _current != null;
    }
    if (_current?.next == null) return false;
    _current = _current!.next;
    return true;
  }
}
