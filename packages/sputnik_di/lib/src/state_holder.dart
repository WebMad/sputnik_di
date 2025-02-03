import 'dart:async';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'lifecycle/lifecycle_export.dart';

/// A base class that holds and manages a state of type [T], providing a stream of state changes.
///
/// Implements the [Lifecycle] interface to allow initialization and disposal.
///
/// Example usage:
/// ```dart
/// class CounterStateHolder extends StateHolder<int> {
///   CounterStateHolder() : super(0);
///
///   void increment() {
///     state = state + 1;
///   }
/// }
///
/// void main() {
///   final counter = CounterStateHolder();
///   counter.stream.listen((value) => print('Counter: \$value'));
///   counter.increment(); // Outputs: Counter: 1
/// }
/// ```
abstract class StateHolder<T> implements Lifecycle {
  /// A broadcast stream controller to manage state updates.
  final _streamController = StreamController<T>.broadcast();

  /// The current state.
  T _state;

  /// Creates a [StateHolder] with an initial state.
  StateHolder(this._state);

  /// Returns the current state.
  T get state => _state;

  /// Updates the state and notifies listeners by adding the new state to the stream.
  @protected
  set state(T newState) {
    _state = newState;
    _streamController.add(newState);
  }

  /// A stream of state updates.
  Stream<T> get stream => _streamController.stream;

  /// A stream that emits the current state first, followed by state updates.
  Stream<T> get asStream => _streamController.stream.startWith(state);

  /// Initializes the state holder. Can be overridden in subclasses.
  @override
  @mustCallSuper
  Future<void> init() async {}

  /// Disposes of resources by closing the stream controller.
  @override
  @mustCallSuper
  Future<void> dispose() async {
    await _streamController.close();
  }
}
