import 'package:sputnik_di/sputnik_di.dart';
import 'package:test/test.dart';

class Singleton {
  final String name;

  Singleton(this.name);
}

class BindSingletonFactoryTest extends DepsNode {
  late final test = bindSingletonFactory((String name) => Singleton(name));
}

void main() {
  test('Bind singleton factory', () async {
    final depsNode = BindSingletonFactoryTest();

    await depsNode.init();

    final singleton1 = depsNode.test('test');
    final singleton2 = depsNode.test('test');

    expect(singleton1.hashCode == singleton2.hashCode, true);
    expect(singleton1.name, 'test');

    final singleton3 = depsNode.test('test2');
    expect(singleton3.hashCode != singleton1.hashCode, true);
    expect(singleton3.name, 'test2');

    await depsNode.dispose();
  });
}
