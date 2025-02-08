import 'package:sputnik_di/sputnik_di.dart';

/// A function type definition for creating a dependency instance of type `T`.
typedef DependencyCreator<T> = T Function();

/// A function type definition for creating a singleton factory instance of type `T` with a parameter of type `Param`.
typedef SingletonFactoryCreator<T, Param> = T Function(Param param);

/// An interface for dependencies that support clearing their stored instances.
abstract class ClearableDependency<T> {
  /// Clears the stored dependency instance.
  void clear();
}

/// A standard dependency wrapper that manages an instance of type `T`.
/// It supports lazy initialization and caching.
class Dependency<T> implements ClearableDependency<T> {
  /// The stored instance of the dependency.
  T? dep;

  /// A function that creates an instance of `T` when needed.
  DependencyCreator<T> _creator;

  /// The dependency node that manages initialization status and lifecycle.
  final DepsNode _depsNode;

  /// Constructor that takes a [DepsNode] and a factory function.
  Dependency(
    this._depsNode,
    this._creator,
  );

  /// Retrieves the stored dependency or creates a new one if it doesn't exist.
  T call() {
    assert(
      _depsNode.status == DepsNodeStatus.initialized || _depsNode.getDepsLock,
      'Incorrect DepsNode status while retrieving dependency.\n'
      'A dependency can only be retrieved when the status '
      'is "initialized" or during the initialization of the initializeQueue.',
    );

    return dep ??= _creator();
  }

  /// Overrides the dependency creator with a new one.
  /// Can only be done when the [DepsNode] is in an idle state.
  void overrideWith(DependencyCreator<T> newCreator) {
    assert(
      _depsNode.status == DepsNodeStatus.idle,
      'The dependency override must occur before the initialization of DepsNode',
    );

    _creator = newCreator;
  }

  /// Clears the stored dependency instance, allowing it to be recreated.
  @override
  void clear() {
    dep = null;
  }
}

/// A dependency wrapper that creates and stores singleton instances based on a parameter.
/// Each parameter value corresponds to a unique instance of `T`.
class SingletonFactoryDependency<T, Param> implements ClearableDependency<T> {
  /// A map storing singleton instances for different parameter values.
  final Map<Param, T> deps = {};

  /// The dependency node that manages initialization status and lifecycle.
  final DepsNode _depsNode;

  /// A function that creates an instance of `T` given a parameter of type `Param`.
  SingletonFactoryCreator<T, Param> _creator;

  /// Constructor that takes a [DepsNode] and a factory function.
  SingletonFactoryDependency(
    this._depsNode,
    this._creator,
  );

  /// Retrieves the singleton instance associated with the given parameter,
  /// creating it if it does not already exist.
  T call(Param param) {
    assert(
      _depsNode.status == DepsNodeStatus.initialized || _depsNode.getDepsLock,
      'Incorrect DepsNode status while retrieving dependency.\n'
      'A dependency can only be retrieved when the status '
      'is "initialized" or during the initialization of the initializeQueue.',
    );

    return deps[param] ??= _creator(param);
  }

  /// Converts a specific parameterized singleton into a standard [Dependency<T>].
  /// This allows treating a singleton with a predefined parameter as a regular dependency.
  Dependency<T> toDependency(Param param) =>
      Dependency(_depsNode, () => _creator(param));

  /// Overrides the singleton factory creator with a new one.
  /// Can only be done when the [DepsNode] is in an idle state.
  void overrideWith(SingletonFactoryCreator<T, Param> newCreator) {
    assert(
      _depsNode.status == DepsNodeStatus.idle,
      'The dependency override must occur before the initialization of DepsNode',
    );

    _creator = newCreator;
  }

  /// Clears all stored singleton instances.
  @override
  void clear() => deps.clear();
}
