import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';
import 'package:sputnik_di/sputnik_di.dart';

class _DepsNodeBinderInh<T extends DepsNode> extends InheritedWidget {
  final T depsNode;

  const _DepsNodeBinderInh({
    super.key,
    required this.depsNode,
    required super.child,
  });

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

class DepsNodeBinder<T extends DepsNode> extends SingleChildStatefulWidget {
  final T Function() depsNode;

  const DepsNodeBinder._({
    super.key,
    super.child,
    required this.depsNode,
  });

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

    depsNode = widget.depsNode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return _DepsNodeBinderInh<T>(
      depsNode: depsNode,
      child: child ?? SizedBox.shrink(),
    );
  }
}

class MultiDepsNodeBinder extends Nested {
  MultiDepsNodeBinder({
    super.key,
    super.child,
    required List<SingleChildWidget> depsNodeBinders,
  }) : super(children: depsNodeBinders);
}

extension DepsNodeBuildContextEx on BuildContext {
  R depsNode<R extends DepsNode>({bool listen = false}) =>
      DepsNodeBinder.of<R>(this, listen: listen);
}
