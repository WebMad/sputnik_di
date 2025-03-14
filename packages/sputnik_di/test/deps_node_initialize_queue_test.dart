import 'package:sputnik_di/sputnik_di.dart';
import 'package:test/test.dart';

const _checkString = 'Hello world!';

class A extends Lifecycle {
  final B _b;
  String? checkField;

  A(this._b);

  @override
  Future<void> init() async {
    checkField = _b.checkField;
  }

  @override
  Future<void> dispose() async {}
}

class B extends Lifecycle {
  String? checkField;

  @override
  Future<void> init() async {
    checkField = _checkString;
  }

  @override
  Future<void> dispose() async {}
}

class InitializeQueueDepsNode extends DepsNode {
  late final a = bind(() => A(b()));
  late final b = bind(() => B());

  @override
  List<Set<LifecycleDependency>> get initializeQueue => [
        {b},
        {a},
      ];
}

void main() {
  test(
    'DepsNode initialize queue',
    () async {
      final initializeQueueDepsNode = InitializeQueueDepsNode();

      await initializeQueueDepsNode.init();

      expect(initializeQueueDepsNode.a().checkField, _checkString);

      await initializeQueueDepsNode.dispose();
    },
  );
}
