import 'package:sputnik_di/sputnik_di.dart';
import 'package:test/test.dart';

class TestDepsNode extends DepsNode {
  @override
  List<Set<LifecycleDependency>> get initializeQueue => [
        {test},
      ];

  late final test = bind(
    () {
      bool alreadyInitialized = false;
      return RawLifecycle(
        onInit: () async {
          if (alreadyInitialized) {
            throw Exception('This dependency already initialized yet');
          }
          alreadyInitialized = true;
        },
        onDispose: () async {},
      );
    },
  );
}

void main() {
  test(
    'DepsNode reinit test',
    () async {
      final testDepsNode = TestDepsNode();

      await testDepsNode.init();
      await testDepsNode.dispose();

      testDepsNode.clear();

      await testDepsNode.init();
      await testDepsNode.dispose();

      testDepsNode.clear();

      await testDepsNode.init();
      await testDepsNode.dispose();
    },
  );
}
