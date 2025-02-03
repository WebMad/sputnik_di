import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sputnik_di/flutter_sputnik_di.dart';

/// A widget that listens to the state changes of a [StateHolder] and calls a listener function.
///
/// This widget subscribes to the stream of a [StateHolder] and invokes the provided listener
/// function whenever the state changes. The widget also provides a child widget that remains static,
/// regardless of state changes.
class StateHolderListener<T extends StateHolder<R>, R> extends StatefulWidget {
  /// The [StateHolder] instance whose state changes will be listened to.
  final T holder;

  /// A listener function that is invoked whenever the state of the [StateHolder] changes.
  ///
  /// The listener receives the current state of type [R] as its argument.
  final void Function(R data) listener;

  /// The child widget that remains unchanged, irrespective of the [StateHolder]'s state changes.
  final Widget child;

  /// Constructs a [StateHolderListener] widget.
  ///
  /// The constructor requires the [holder] parameter (the [StateHolder] instance to listen to),
  /// the [listener] function (called whenever the state changes), and the [child] widget (the widget
  /// to be rendered regardless of state changes).
  const StateHolderListener({
    super.key,
    required this.holder,
    required this.listener,
    required this.child,
  });

  @override
  State<StateHolderListener> createState() => _StateHolderListenerState<T, R>();
}

class _StateHolderListenerState<T extends StateHolder<R>, R>
    extends State<StateHolderListener<T, R>> {
  StreamSubscription<R>? _sub;

  @override
  void initState() {
    super.initState();

    // Subscribes to the [StateHolder]'s stream and calls the listener when the state changes.
    _sub = widget.holder.stream.listen((event) => widget.listener(event));
  }

  @override
  void dispose() {
    // Cancels the stream subscription when the widget is disposed.
    _sub?.cancel();
    _sub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always returns the child widget, regardless of state changes.
    return widget.child;
  }
}
