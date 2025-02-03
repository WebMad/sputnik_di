import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';
import 'package:sputnik_di/sputnik_di.dart';

/// InheritedWidget that provides a [DepsNode] instance to its descendant widgets.
///
/// The [DepsNode] is provided through this widget to enable access via the `of` method.
class _DepsNodeBinderInh<T extends DepsNode> extends InheritedWidget {
  /// The [DepsNode] instance provided by this widget.
  final T depsNode;

  const _DepsNodeBinderInh({
    super.key,
    required this.depsNode,
    required super.child,
  });

  /// Retrieves the [DepsNode] instance from the nearest ancestor [DepsNodeBinder] widget.
  ///
  /// The [listen] flag determines whether the widget should listen for changes to the [DepsNode].
  /// If [listen] is true, this method will rebuild widgets when the [DepsNode] changes.
  ///
  /// Throws an assertion error if no [DepsNodeBinder] is found in the widget tree.
  static R of<R extends DepsNode>(BuildContext context, {bool listen = false}) {
    final result = listen
        ? context.dependOnInheritedWidgetOfExactType<_DepsNodeBinderInh<R>>()
        : context.findAncestorWidgetOfExactType<_DepsNodeBinderInh<R>>();

    assert(result != null, 'No DepsNodeBinder found in context');
    return result!.depsNode;
  }

  @override
  bool updateShouldNotify(_DepsNodeBinderInh old) => old.depsNode != depsNode;
}

/// A widget that binds a [DepsNode] instance to the widget tree.
///
/// The [DepsNode] can be provided either through a function that returns the [DepsNode]
/// or directly via the [value] factory constructor. This widget can be accessed by
/// other widgets using the [DepsNodeBinder.of] method.
class DepsNodeBinder<T extends DepsNode> extends SingleChildStatefulWidget {
  /// A function that returns a new instance of the [DepsNode].
  final T Function() depsNode;

  const DepsNodeBinder._({
    super.key,
    super.child,
    required this.depsNode,
  });

  /// A factory constructor that creates a [DepsNodeBinder] with a function to provide the [DepsNode].
  factory DepsNodeBinder({
    Key? key,
    required T Function() depsNode,
    Widget? child,
  }) =>
      DepsNodeBinder<T>._(
        child: child,
        key: key,
        depsNode: depsNode,
      );

  /// A factory constructor that creates a [DepsNodeBinder] with a fixed [DepsNode] instance.
  factory DepsNodeBinder.value({
    Key? key,
    required T depsNode,
    Widget? child,
  }) =>
      DepsNodeBinder<T>._(
        key: key,
        depsNode: () => depsNode,
        child: child,
      );

  /// Retrieves the [DepsNode] instance from the nearest [DepsNodeBinder] widget.
  ///
  /// The [listen] flag determines whether the widget should rebuild when the [DepsNode] changes.
  static R of<R extends DepsNode>(
    BuildContext context, {
    bool listen = false,
  }) =>
      _DepsNodeBinderInh.of<R>(context, listen: listen);

  @override
  State<DepsNodeBinder<T>> createState() => _DepsNodeBinderState<T>();
}

class _DepsNodeBinderState<T extends DepsNode>
    extends SingleChildState<DepsNodeBinder<T>> {
  late final T depsNode;

  @override
  void initState() {
    super.initState();

    // Initialize the [DepsNode] instance by invoking the provided function.
    depsNode = widget.depsNode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    // Provide the [DepsNode] instance to the widget tree via the [_DepsNodeBinderInh] widget.
    return _DepsNodeBinderInh<T>(
      depsNode: depsNode,
      child: child ?? SizedBox.shrink(),
    );
  }
}

/// A widget that allows multiple [DepsNodeBinder] widgets to be included as children.
///
/// This widget is useful when you need to manage multiple [DepsNode] bindings
/// within a single widget subtree. Each child [DepsNodeBinder] can provide
/// a separate instance of a [DepsNode] to the widget tree.
class MultiDepsNodeBinder extends Nested {
  /// Constructs a [MultiDepsNodeBinder] widget.
  ///
  /// The constructor accepts a list of [SingleChildWidget]s, which are expected
  /// to be instances of [DepsNodeBinder]. These binders will be placed as children
  /// of the [MultiDepsNodeBinder] and manage their respective [DepsNode] instances.
  ///
  /// The [key] and [child] parameters are passed to the [Nested] superclass.
  MultiDepsNodeBinder({
    super.key,
    super.child,
    required List<SingleChildWidget> depsNodeBinders,
  }) : super(children: depsNodeBinders);
}

/// Extension on [BuildContext] to retrieve the [DepsNode] instance using the [DepsNodeBinder.of] method.
///
/// This extension simplifies accessing the [DepsNode] from any context.
extension DepsNodeBuildContextEx on BuildContext {
  R depsNode<R extends DepsNode>({bool listen = false}) =>
      DepsNodeBinder.of<R>(this, listen: listen);
}
