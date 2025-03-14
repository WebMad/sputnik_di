import 'package:sputnik_di/sputnik_di.dart';
import 'package:test/test.dart';

class TestStateHolder extends StateHolder<bool> {
  TestStateHolder() : super(false);

  void enable() => state = true;

  void disable() => state = false;
}

void main() {
  test('StateHolder test', () async {
    final testStateHolder = TestStateHolder();

    bool? test;

    final sub = testStateHolder.stream.listen((event) => test = event);

    testStateHolder.enable();
    await null;

    expect(test, true);
    expect(testStateHolder.state, true);

    await sub.cancel();
    await testStateHolder.dispose();

    expect(() => testStateHolder.enable(), throwsStateError);
  });
}
