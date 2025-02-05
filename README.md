# Lightweight DI for your Dart project

## Getting started

For a Dart project:

```shell
dart pub add sputnik_di
```

Or for a Flutter project:

```shell
dart pub add flutter_sputnik_di
```

Everything revolves around `DepsNode` (Dependency Node). A Dependency Node is an atomic unit of your
code. It can serve as both a dependency container for your feature and as a scope for your
application, such as `AppScopeDepsNode`, `AuthScopeDepsNode`, `OrderScopeDepsNode`, etc.

```dart
import 'package:flutter_sputnik_di/flutter_sputnik_di.dart';

Future<void> main() async {
  final featureDepsNode = FeatureDepsNode();

  await featureDepsNode.init();

  final featureManager = featureDepsNode.featureManager();

  // using featureManager
}

/// Dependency Node
class FeatureDepsNode extends DepsNode {
  @override
  @protected
  List<Set<LifecycleDependency>> initializeQueue = [
    {
      featureManager,
    },
  ];

  late final featureManager = bind(() => FeatureManager());
}

class FeatureManager implements Lifecycle {
  Future<void> init() {
    // ...
  }

  Future<void> dispose() {
    // ...
  }
}
```

All dependencies described in the dependency node must be wrapped in the `bind` method. This method
creates a callback that, when calling a dependency, checks whether the current dependency node has
been disposed of. Additionally, it acts as a wrapper for controlling calls in `initializeQueue`.
This ensures that dependencies are not accessed before the node is initialized.

Of course, this does not completely eliminate the problem of early dependency calls, especially in
production code where `assert` is used. However, this is a trade-off for ease of use and reducing
the number of created entities.

## Using with Flutter

```dart
class FeatureWidget extends StatefulWidget {
  final Widget child;

  const FeatureWidget({
    required this.child,
    super.key
  });

  @override
  State<FeatureWidget> createState() => _FeatureWidgetState();
}

class _FeatureWidgetState extends State<FeatureWidget> {
  late final FeatureDepsNode featureDepsNode;

  @override
  void initState() {
    super.initState();

    featureDepsNode = FeatureDepsNode();
    unawaited(featureDepsNode.init());
  }

  @override
  void dispose() {
    unawaited(featureDepsNode.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DepsNodeBuilder(
      depsNode: featureDepsNode,
      initialized: (context, depsNode) {
        final featureManager = depsNode.featureManager();

        // using featureManager

        return DepsNodeBinder(
          depsNode: featureDepsNode,
          child: widget.child,
        );
      },
      orElse: (context, depsNode) {
        return Center(Text('Current depsNode status = ${depsNode.status}'));
      },
    );
  }
}
```

## Built-in Simple State Management

We are used to advanced state management systems, but they are not always convenient. In most cases,
a simpler system is sufficient, and in `sputnik_di`, this model looks as follows:

```dart
class FeatureStateHolder extends StateHolder<String> {
  FeatureStateHolder() : super('DefaultValue');

  void updateState(String newState) {
    state = newState;
  }
}

class FeatureManager implements Lifecycle {
  final FeatureStateHolder _featureStateHolder;

// ...
}

class FeatureDepsNode extends DepsNode {
  @override
  @protected
  List<Set<LifecycleDependency>> initializeQueue = [];

  @override
  @protected
  List<Set<LifecycleDependency>> initializeQueue = [
    {
      /// Should be disposed after depsNode is disposed
      featureStateHolder,
    },
    {
      featureManager,
    },
  ];

  late final featureManager = bind(() => FeatureManager());

  late final featureStateHolder = bind(() => FeatureStateHolder());
}

class FeatureWidget extends StatelessWidget {
  const FeatureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final featureDepsNode = context.depsNode<FeatureDepsNode>();

    // rebuild on state change
    return StateHolderBuilder(
        holder: featureDepsNode.featureStateHolder(),
        builder: (context, state) {
          // listen to events from the state holder
          return StateHolderListener(
            listener: (data) {},
            holder: featureDepsNode.featureStateHolder(),
            child: const SizedBox.shrink(),
          );
        }
    );
  }
}
```

## Additional information

The package includes a `Lifecycle` class, which is structured as follows:

```dart
abstract class Lifecycle {
  Future<void> init();

  Future<void> dispose();
}
```

It is used for classes that have a lifecycle. They can be registered in the dependency node via
the `initializeQueue` getter.

## Contributing and Support

If you have any ideas, feature requests, or issues, feel free to open an issue or submit a pull
request in the [GitHub repository](https://github.com/WebMad/sputnik_di). Your feedback is highly
appreciated!

If you like this project and want to support me, you can do so
via [Boosty](https://boosty.to/gubin-dev/donate). Every contribution helps keep this project alive
and growing. Thank you! 😊  
