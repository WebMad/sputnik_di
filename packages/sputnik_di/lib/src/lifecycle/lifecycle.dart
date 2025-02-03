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
