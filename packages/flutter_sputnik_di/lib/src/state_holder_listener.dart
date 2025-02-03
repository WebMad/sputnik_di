import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sputnik_di/flutter_sputnik_di.dart';

class StateHolderListener<T extends StateHolder<R>, R> extends StatefulWidget {
  final T holder;
  final void Function(R data) listener;
  final Widget child;

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

    _sub = widget.holder.stream.listen((event) => widget.listener(event));
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
