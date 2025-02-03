import 'package:flutter/material.dart';
import 'package:sputnik_di/sputnik_di.dart';

/// A widget that rebuilds based on the state of a [StateHolder].
///
/// This widget listens to the [StateHolder]'s state stream and rebuilds its UI
/// whenever the state changes. It uses a builder function to construct the widget
/// based on the current state.
class StateHolderBuilder<Holder extends StateHolder<T>, T>
    extends StatelessWidget {
  /// A function that takes the [BuildContext] and the current [state] and returns a widget.
  ///
  /// This function is used to build the widget UI based on the current state of the [StateHolder].
  final Widget Function(BuildContext context, T state) builder;

  /// The [StateHolder] instance whose state will be monitored and used to rebuild the UI.
  final Holder holder;

  /// Constructs a [StateHolderBuilder] widget.
  ///
  /// The constructor requires the [builder] function that takes the [BuildContext]
  /// and the state of type [T], and returns the corresponding widget.
  /// It also requires the [holder] parameter, which represents the [StateHolder]
  /// instance that holds the state.
  const StateHolderBuilder({
    required this.builder,
    required this.holder,
    super.key,
  });

  @override
  Widget build(BuildContext context) => StreamBuilder<T>(
    initialData: holder.state,
    stream: holder.stream,
    builder: (context, snapshot) => builder(context, snapshot.requireData),
  );
}
