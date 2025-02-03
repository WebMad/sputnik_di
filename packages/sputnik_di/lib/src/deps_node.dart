import 'dart:async';
import 'package:meta/meta.dart';
import 'package:sputnik_di/sputnik_di.dart';

/// A function type representing a dependency that implements [Lifecycle].
typedef LifecycleDependency = Lifecycle Function();

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
  @protected
  List<Set<LifecycleDependency>> initializeQueue = [];

  /// A broadcast stream controller to manage status updates.
  final StreamController<DepsNodeStatus> _statusController =
      StreamController<DepsNodeStatus>.broadcast();

  /// A flag to indicate whether dependencies are being retrieved.
  bool _getDepsLock = false;

  /// The current status of the [DepsNode].
  DepsNodeStatus _status = DepsNodeStatus.idle;

  /// A stream that emits status updates for the [DepsNode].
  Stream<DepsNodeStatus> get statusStream => _statusController.stream;

  /// Returns the current status of the [DepsNode].
  DepsNodeStatus get status => _status;

  /// Updates the status and notifies listeners via the stream.
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
      _getDepsLock = false;

      await Future.wait(futures);
    }
    _setStatus(DepsNodeStatus.initialized);
  }

  /// Disposes all dependencies in the queue in reverse order.
  ///
  /// This method sets the status to [DepsNodeStatus.disposing],
  /// processes each batch of dependencies in reverse order, and then sets
  /// the status to [DepsNodeStatus.disposed].
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
  @protected
  R Function() bind<R>(R Function() creator) {
    final dep = creator();

    return () {
      assert(
        _status == DepsNodeStatus.initialized || _getDepsLock,
        'Incorrect DepsNode status while retrieving dependency.\n'
        'A dependency can only be retrieved when the status '
        'is "initialized" or during the initialization of the initializeQueue.',
      );

      return dep;
    };
  }
}
