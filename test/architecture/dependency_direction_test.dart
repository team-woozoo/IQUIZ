import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Iterable<File> _dartFiles(String path) => Directory(path)
    .listSync(recursive: true)
    .whereType<File>()
    .where(
      (file) => file.path.endsWith('.dart') && !file.path.endsWith('.g.dart'),
    );

Iterable<String> _imports(File file) =>
    RegExp(r'''(?:import|export)\s+['"]([^'"]+)['"]''')
        .allMatches(file.readAsStringSync())
        .map((match) => match.group(1)!);

void main() {
  test('화면은 DataSource와 AppDio를 직접 참조하지 않는다', () {
    final violations = <String>[];
    for (final file in _dartFiles('lib/presentation')) {
      for (final dependency in _imports(file)) {
        if (dependency.contains('/data_source/') ||
            dependency == 'package:iquiz/app/network/app_dio.dart') {
          violations.add('${file.path} → $dependency');
        }
      }
    }
    expect(violations, isEmpty);
  });

  test('네트워크는 기능 구현, DI, 화면, 앱 진입점을 참조하지 않는다', () {
    final violations = <String>[];
    for (final file in _dartFiles('lib/app/network')) {
      for (final dependency in _imports(file)) {
        if (dependency.startsWith('package:iquiz/features/') ||
            dependency.startsWith('package:iquiz/presentation/') ||
            dependency.startsWith('package:iquiz/app/di/') ||
            dependency == 'package:iquiz/main.dart') {
          violations.add('${file.path} → $dependency');
        }
      }
    }
    expect(violations, isEmpty);
  });

  test('공통 코드는 app, features, presentation을 참조하지 않는다', () {
    final violations = <String>[];
    for (final file in _dartFiles('lib/core')) {
      for (final dependency in _imports(file)) {
        if (dependency.startsWith('package:iquiz/') &&
            !dependency.startsWith('package:iquiz/core/')) {
          violations.add('${file.path} → $dependency');
        }
      }
    }
    expect(violations, isEmpty);
  });

  test('Entity는 DataSource와 통신 Model을 참조하지 않는다', () {
    final violations = <String>[];
    for (final file in _dartFiles(
      'lib/features',
    ).where((file) => file.path.contains('/repositories/entities/'))) {
      for (final dependency in _imports(file)) {
        if (dependency.contains('/data_source/') ||
            dependency.contains('/models/')) {
          violations.add('${file.path} → $dependency');
        }
      }
    }
    expect(violations, isEmpty);
  });
}
