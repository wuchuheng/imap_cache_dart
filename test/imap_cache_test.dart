import 'dart:io';

import 'package:test/test.dart';
import 'package:wuchuheng_env/wuchuheng_env.dart';

void main() {
  group('A group of tests', () {
    // final awesome = Awesome();

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      final file = '${Directory.current.path}/test/.env';
      final env = Load(file: file).env;
      print(env['USER_NAME']);
      // expect(awesome.isAwesome, isTrue);
    });
  });
}
