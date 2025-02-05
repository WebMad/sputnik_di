import 'package:flutter/material.dart';
import 'package:flutter_sputnik_di/flutter_sputnik_di.dart';

/// A widget that builds different UI states based on the status of a [DepsNode].
///
/// This widget listens to the [DepsNode] status and provides different widgets
/// depending on whether the [DepsNode] is idle, initializing, initialized, disposing, or disposed.
/// Each state has an associated builder function that is executed when the respective state is active.
class DepsNodeBuilder<T extends DepsNode> extends StatelessWidget {
  /// The [DepsNode] instance whose status will be monitored and used to determine which widget to display.
  final T depsNode;

  /// Determines whether the [depsNode] should be bound when it is initialized.
  ///
  /// If set to `true`, the [DepsNode] will automatically be wrapped with [DepsNodeBinder.value]
  /// when it reaches the initialized state. This ensures that the node is available
  /// for dependency injection within the widget subtree. If `false`, the binding
  /// must be handled manually if needed.
  final bool bindOnInitialized;

  /// A builder function for when the [DepsNode] is idle.
  ///
  /// This function is called when the [DepsNode] is in the idle state.
  /// The function may return a widget, or `null` if no widget is provided.
  final Widget Function(
    BuildContext context,
    T depsNode,
  )? idle;

  /// A builder function for when the [DepsNode] is initializing.
  ///
  /// This function is called when the [DepsNode] is in the initializing state.
  /// The function may return a widget, or `null` if no widget is provided.
  final Widget Function(
    BuildContext context,
    T depsNode,
  )? initializing;

  /// A builder function for when the [DepsNode] is disposing.
  ///
  /// This function is called when the [DepsNode] is in the disposing state.
  /// The function may return a widget, or `null` if no widget is provided.
  final Widget Function(
    BuildContext context,
    T depsNode,
  )? disposing;

  /// A builder function for when the [DepsNode] is disposed.
  ///
  /// This function is called when the [DepsNode] is in the disposed state.
  /// The function may return a widget, or `null` if no widget is provided.
  final Widget Function(
    BuildContext context,
    T depsNode,
  )? disposed;

  /// A builder function for when the [DepsNode] is initialized.
  ///
  /// This function is called when the [DepsNode] has completed initialization.
  /// It always returns a widget since this state is always expected to have a corresponding UI.
  final Widget Function(
    BuildContext context,
    T depsNode,
  ) initialized;

  /// A fallback builder function for any state that does not have a specific builder function.
  ///
  /// This function is called when no specific builder is provided for a given state.
  /// It will return a widget for any state not explicitly handled.
  final Widget Function(
    BuildContext context,
    T depsNode,
  ) orElse;

  /// Constructs a [DepsNodeBuilder] widget.
  ///
  /// The constructor requires the [depsNode] parameter, which represents the [DepsNode]
  /// instance whose status will determine which widget to display. It also accepts
  /// optional builder functions for different [DepsNode] statuses, such as [initializing],
  /// [disposing], [disposed], and [idle]. The [initialized] function is required and
  /// is called when the [DepsNode] is in the initialized state. The [orElse] function is
  /// a fallback that will be used if no builder is provided for a particular state.
  ///
  /// The builder functions are invoked based on the [DepsNode] status, and the widget tree
  /// is updated accordingly.
  const DepsNodeBuilder({
    super.key,
    required this.depsNode,
    this.initializing,
    this.disposing,
    this.disposed,
    this.idle,
    this.bindOnInitialized = false,
    required this.initialized,
    required this.orElse,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: depsNode.status,
      stream: depsNode.statusStream,
      builder: (context, snapshot) {
        final status = snapshot.requireData;

        // Switches based on the [DepsNode] status and calls the appropriate builder function.
        switch (status) {
          case DepsNodeStatus.idle:
            final res = idle?.call(context, depsNode);
            if (res != null) {
              return res;
            }
            break;
          case DepsNodeStatus.initializing:
            final res = initializing?.call(context, depsNode);
            if (res != null) {
              return bindOnInitialized
                  ? DepsNodeBinder.value(depsNode: depsNode, child: res)
                  : res;
            }
            break;
          case DepsNodeStatus.initialized:
            final res = initialized.call(context, depsNode);

            return bindOnInitialized
                ? DepsNodeBinder.value(depsNode: depsNode, child: res)
                : res;
          case DepsNodeStatus.disposing:
            final res = disposing?.call(context, depsNode);
            if (res != null) {
              return res;
            }
            break;
          case DepsNodeStatus.disposed:
            final res = disposed?.call(context, depsNode);
            if (res != null) {
              return res;
            }
            break;
        }

        // If no specific builder was called, use the fallback function.
        return orElse(context, depsNode);
      },
    );
  }
}
