import 'package:sputnik_di/sputnik_di.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class Test implements Lifecycle {
  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {}
}

class Test2 extends Test {}

class TestDepsNode extends DepsNode {
  late final test = bind(() => Test());

  @override
  List<Set<LifecycleDependency>> get initializeQueue => [
        {
          test,
        },
      ];
}

void main() {
  test(
    'DepsNode lifecycle test',
    () async {
      final testDepsNode = TestDepsNode();
      expect(testDepsNode.status, DepsNodeStatus.idle);

      final initFuture = testDepsNode.init();
      expect(testDepsNode.status, DepsNodeStatus.initializing);

      await initFuture;
      expect(testDepsNode.status, DepsNodeStatus.initialized);

      final oldTest = testDepsNode.test();

      final disposeFuture = testDepsNode.dispose();
      expect(testDepsNode.status, DepsNodeStatus.disposing);

      await disposeFuture;
      expect(testDepsNode.status, DepsNodeStatus.disposed);

      testDepsNode.clear();

      expect(testDepsNode.status, DepsNodeStatus.idle);
      await testDepsNode.init();

      expect(testDepsNode.test().hashCode != oldTest.hashCode, true);

      await testDepsNode.dispose();
    },
  );

  test('DepsNode overrideWith test', () async {
    final testDepsNode = TestDepsNode();

    testDepsNode.test.overrideWith(() => Test2());

    await testDepsNode.init();

    expect(testDepsNode.test() is Test2, true);

    expect(
      () => testDepsNode.test.overrideWith(() => Test()),
      throwsA(isA<AssertionError>()),
    );
  });
}
