import 'package:flutter/material.dart';
import 'package:flutter_sputnik_di/flutter_sputnik_di.dart';

class DepsNodeBuilder<T extends DepsNode> extends StatelessWidget {
  final T depsNode;

  final Widget Function(
    BuildContext context,
    T depsNode,
  )? idle;

  final Widget Function(
    BuildContext context,
    T depsNode,
  )? initializing;

  final Widget Function(
    BuildContext context,
    T depsNode,
  )? disposing;

  final Widget Function(
    BuildContext context,
    T depsNode,
  )? disposed;

  final Widget Function(
    BuildContext context,
    T depsNode,
  ) initialized;

  final Widget Function(
    BuildContext context,
    T depsNode,
  ) orElse;

  const DepsNodeBuilder({
    super.key,
    required this.depsNode,
    this.initializing,
    this.disposing,
    this.disposed,
    this.idle,
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
              return res;
            }
            break;
          case DepsNodeStatus.initialized:
            return initialized.call(context, depsNode);
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

        return orElse(context, depsNode);
      },
    );
  }
}
