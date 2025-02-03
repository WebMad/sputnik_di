import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sputnik_di/sputnik_di.dart';

typedef LifecycleDependency = Lifecycle Function();

enum DepsNodeStatus {
  idle,
  initializing,
  initialized,
  disposing,
  disposed,
}

abstract class DepsNode implements Lifecycle {
  @protected
  List<Set<LifecycleDependency>> initializeQueue = [];

  final StreamController<DepsNodeStatus> _statusController =
      StreamController<DepsNodeStatus>.broadcast();

  bool _getDepsLock = false;

  DepsNodeStatus _status = DepsNodeStatus.idle;

  Stream<DepsNodeStatus> get statusStream => _statusController.stream;

  DepsNodeStatus get status => _status;

  void _setStatus(DepsNodeStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(newStatus);
    }
  }

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
