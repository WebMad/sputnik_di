/// The abstract class [Lifecycle] defines methods for initialization and resource cleanup,
/// which must be implemented by subclasses.
///
/// It is used to manage the lifecycle of objects, such as opening and closing resources
/// or connecting and disconnecting from services.
abstract class Lifecycle {
  /// The initialization method that is called to prepare the object or resource
  /// for use. The implementation of this method should perform any necessary setup
  /// and initialization.
  ///
  /// Return value: [Future] will complete when initialization is finished.
  Future<void> init();

  /// A method for releasing resources and performing cleanup before the object is destroyed.
  /// This method should be called when the object is no longer needed or before it is removed.
  ///
  /// Return value: [Future] will complete when all resources are released.
  Future<void> dispose();
}

/// A basic implementation of the [Lifecycle] interface.
///
/// This class allows defining lifecycle behavior through callbacks for initialization
/// and disposal. It provides a simple way to manage lifecycle events by passing
/// functions to [onInit] and [onDispose].
class RawLifecycle implements Lifecycle {
  /// A function that is called when the lifecycle is initialized.
  ///
  /// This function should contain any necessary setup logic.
  final Future<void> Function() onInit;

  /// A function that is called when the lifecycle is disposed.
  ///
  /// This function should contain any cleanup logic.
  final Future<void> Function() onDispose;

  /// Constructs a [RawLifecycle] with the required lifecycle callbacks.
  ///
  /// The [onInit] function is called when [init] is executed, and the [onDispose]
  /// function is called when [dispose] is executed.
  RawLifecycle({
    required this.onInit,
    required this.onDispose,
  });

  /// Calls the [onInit] function to initialize the lifecycle.
  @override
  Future<void> init() async {
    await onInit();
  }

  /// Calls the [onDispose] function to clean up resources.
  @override
  Future<void> dispose() async {
    await onDispose();
  }
}
