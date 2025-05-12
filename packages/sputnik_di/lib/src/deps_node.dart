import 'dart:async';
import 'package:meta/meta.dart';

import 'dependency.dart';
import 'lifecycle/lifecycle.dart';

/// A function type representing a dependency that implements [Lifecycle].
typedef LifecycleDependency = Dependency<Lifecycle>;

/// Represents the possible statuses of a [DepsNode].
enum DepsNodeStatus {
  /// The node is idle and has not started initialization.
  idle,

  /// The node is in the process of initializing dependencies.
  initializing,

  /// The node has completed initialization and is ready to use.
  initialized,

  /// The node is in the process of disposing dependencies.
  disposing,

  /// The node has been fully disposed and is no longer usable.
  disposed,
}

/// A base class for managing lifecycle-bound dependencies.
///
/// Implements the [Lifecycle] interface to ensure proper initialization and disposal
/// of dependencies in a controlled manner.
abstract class DepsNode implements Lifecycle {
  /// The queue of dependency sets that need to be initialized.
  ///
  /// Dependencies are initialized in batches, with each set being processed sequentially.
  @protected
  List<Set<LifecycleDependency>> initializeQueue = [];

  /// A set of dependencies that can be cleared when needed.
  final Set<ClearableDependency> _clearableDependencies = {};

  /// A broadcast stream controller to manage status updates.
  StreamController<DepsNodeStatus>? _internalStatusController;

  /// A flag to indicate whether dependencies are being retrieved.
  ///
  /// This ensures that dependencies can only be accessed during initialization
  /// or when the node is fully initialized.
  bool _getDepsLock = false;

  /// The current status of the [DepsNode].
  DepsNodeStatus _status = DepsNodeStatus.idle;

  /// Whether dependencies can currently be retrieved.
  ///
  /// This is `true` during initialization and `false` otherwise.
  @internal
  bool get getDepsLock => _getDepsLock;

  /// Ensures getting the current StatusController
  StreamController<DepsNodeStatus> get _statusController =>
      _internalStatusController ??=
      StreamController<DepsNodeStatus>.broadcast();

  /// A stream that emits status updates for the [DepsNode].
  Stream<DepsNodeStatus> get statusStream => _statusController.stream;

  /// Returns the current status of the [DepsNode].
  DepsNodeStatus get status => _status;

  /// Updates the status and notifies listeners via the stream.
  ///
  /// If the new status is different from the current one, the status is updated
  /// and the change is broadcasted to listeners.
  void _setStatus(DepsNodeStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(newStatus);
    }
  }

  /// Initializes all dependencies in the queue.
  ///
  /// This method sets the status to [DepsNodeStatus.initializing],
  /// processes each batch of dependencies sequentially, and then sets
  /// the status to [DepsNodeStatus.initialized].
  ///
  /// Each batch of dependencies is initialized concurrently using [Future.wait].
  @override
  @mustCallSuper
  Future<void> init() async {
    _setStatus(DepsNodeStatus.initializing);
    for (final initializeBatch in initializeQueue) {
      final futures = <Future>[];

      _getDepsLock = true;
      for (final obj in initializeBatch) {
        futures.add(obj().init());
      }


      await Future.wait(futures);

      _getDepsLock = false;
    }
    _setStatus(DepsNodeStatus.initialized);
  }

  /// Disposes all dependencies in the queue in reverse order.
  ///
  /// This method sets the status to [DepsNodeStatus.disposing],
  /// processes each batch of dependencies in reverse order, and then sets
  /// the status to [DepsNodeStatus.disposed].
  ///
  /// Each batch of dependencies is disposed of concurrently using [Future.wait].
  @override
  @mustCallSuper
  Future<void> dispose() async {
    _setStatus(DepsNodeStatus.disposing);
    for (final initializeBatch in initializeQueue.reversed) {
      final futures = <Future>[];

      _getDepsLock = true;
      for (final obj in initializeBatch) {
        futures.add(obj().dispose());
      }
      _getDepsLock = false;

      await Future.wait(futures);
    }
    _setStatus(DepsNodeStatus.disposed);
    _statusController.close();
  }

  /// Binds a dependency to be retrieved safely.
  ///
  /// Ensures that dependencies are only accessed when the [DepsNode] is fully initialized
  /// or during initialization.
  ///
  /// The created dependency is stored in [_clearableDependencies] to allow resetting if needed.
  @protected
  Dependency<R> bind<R>(DependencyCreator<R> creator) {
    final dependency = Dependency(this, creator);
    _clearableDependencies.add(dependency);

    return dependency;
  }

  /// Binds a singleton factory dependency that creates instances based on a parameter.
  ///
  /// Each unique parameter value will be associated with a different singleton instance.
  ///
  /// The created dependency is stored in [_clearableDependencies] to allow resetting if needed.
  @protected
  SingletonFactoryDependency<R, Param> bindSingletonFactory<R, Param>(
      SingletonFactoryCreator<R, Param> creator,) {
    final dependency = SingletonFactoryDependency(
      this,
      creator,
    );

    _clearableDependencies.add(dependency);

    return dependency;
  }

  /// Clears all stored dependencies and resets the node's status to [DepsNodeStatus.idle].
  ///
  /// This ensures that all dependencies can be reinitialized if needed.
  void clear() {
    final depsToClear = [..._clearableDependencies];

    for (final depToClear in depsToClear) {
      depToClear.clear();
    }

    _internalStatusController = null;
    _setStatus(DepsNodeStatus.idle);
  }
}
