import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'swagger/model_generation.dart';

/// 루트 패키지의 swagger_parser와 build_runner로 기능별 모델을 생성
Future<void> main(List<String> arguments) async {
  if (arguments.contains('--help')) {
    stdout.writeln(
      'dart run tool/generate_swagger_models.dart [--refresh]\n'
      '기본: tool/openapi.json 사용 / --refresh: 서버 명세를 갱신한 뒤 생성',
    );
    return;
  }
  if (arguments.any((argument) => argument != '--refresh')) {
    throw ArgumentError('지원하는 옵션: --refresh, --help');
  }
  final root = File.fromUri(Platform.script).parent.parent.path;
  final config = jsonDecode(
    File(p.join(root, 'tool/swagger_models.json')).readAsStringSync(),
  ) as Map<String, dynamic>;
  final schema = File(p.join(root, 'tool/openapi.json'));
  final source = arguments.contains('--refresh')
      ? await _downloadSchema(
          Platform.environment['SWAGGER_SCHEMA_URL'] ??
              config['schemaUrl'] as String,
        )
      : schema.readAsStringSync();

  // 경로·파일명·참조 타입 등록을 파일 수정 전에 검증
  final plan = ModelGenerationPlan(source, config);
  validateExternalFiles(root, plan);
  if (plan.skippedDisabled.isNotEmpty) {
    stdout.writeln(
      'false로 비활성화된 모델·enum 제외: ${plan.skippedDisabled.join(', ')}',
    );
  }
  if (plan.externalDestinations.isNotEmpty) {
    stdout.writeln(
      '수동 관리 파일 보존: ${plan.externalDestinations.values.join(', ')}',
    );
  }
  if (plan.skippedUnregistered.isNotEmpty) {
    stdout.writeln('미등록 모델·enum 제외: ${plan.skippedUnregistered.join(', ')}');
  }
  if (plan.skippedEmpty.isNotEmpty) {
    stdout.writeln('본문이 없거나 비어 있는 모델 제외: ${plan.skippedEmpty.join(', ')}');
  }
  if (!plan.shouldReconcileFiles) {
    stdout.writeln('등록된 생성 대상이 없습니다. 파일 생성·수정·정리를 하지 않습니다.');
    return;
  }
  final manifest = File(p.join(root, 'tool/swagger_models_manifest.json'));
  final previousManifest = manifest.existsSync()
      ? jsonDecode(manifest.readAsStringSync()) as Map<String, dynamic>
      : <String, dynamic>{};
  final previous = List<String>.from(previousManifest['files'] as List? ?? []);
  final previousHeaders = Map<String, String>.from(
    previousManifest['headers'] as Map? ?? {},
  );
  final expected = generatedPaths(plan.featureFiles);
  final stale = staleGeneratedPaths(plan, previous);
  _ensureGenerated(root, {...expected, ...stale}, previousHeaders);
  final formattedSource =
      '${const JsonEncoder.withIndent('  ').convert(jsonDecode(source))}\n';

  _writeFiles(root, plan.featureFiles);
  for (final path in stale) {
    final file = _managedFile(root, path);
    if (file.existsSync()) file.deleteSync();
    // 이전 생성 경로의 빈 generated 폴더도 정리
    final directory = file.parent;
    if (p.basename(directory.path) == 'generated' &&
        directory.existsSync() &&
        directory.listSync().isEmpty) {
      directory.deleteSync();
    }
  }
  schema.writeAsStringSync(formattedSource);

  if (expected.isNotEmpty) {
    final build = await Process.start(
      Platform.resolvedExecutable,
      ['run', 'build_runner', 'build'],
      workingDirectory: root,
      mode: ProcessStartMode.inheritStdio,
    );
    final status = await build.exitCode;
    if (status != 0) throw StateError('JSON 변환 코드 생성 실패: $status');
  }
  final missing = expected.where(
    (path) => !_managedFile(root, path).existsSync(),
  );
  if (missing.isNotEmpty) throw StateError('생성되지 않은 파일: ${missing.join(', ')}');

  manifest.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert({
      'generator': 'swagger_parser 1.45.0',
      'features': plan.featureCounts,
      'files': expected.toList()..sort(),
      'headers': {for (final entry in plan.featureFiles.entries) entry.key: entry.value.split('\n').firstWhere((line) => line.startsWith('/// '))},
    })}\n',
  );
  for (final entry in plan.featureCounts.entries) {
    stdout.writeln(
      '${entry.key}: 모델·enum ${entry.value}개 → ${plan.outputDirectories[entry.key]!.join(', ')}',
    );
  }
  if (expected.isEmpty) {
    stdout.writeln('활성화된 생성 대상이 없습니다. 이전 생성 파일 ${stale.length}개를 정리했습니다.');
  }
}

/// 비어 있는 설정의 보존 정책과 명시적 비활성화의 정리 정책을 구분
Set<String> staleGeneratedPaths(
  ModelGenerationPlan plan,
  Iterable<String> previous,
) => plan.shouldReconcileFiles
    ? previous
          .toSet()
          .difference(generatedPaths(plan.featureFiles))
          .difference(plan.preservedPaths)
    : <String>{};

/// 수동 타입의 경로 오타·누락을 파일 생성 전에 확인
void validateExternalFiles(String root, ModelGenerationPlan plan) {
  final missing = plan.requiredExternalPaths.where(
    (path) => !_managedFile(root, path).existsSync(),
  );
  if (missing.isNotEmpty) {
    throw StateError(
      '참조하는 수동 모델·enum 파일이 없습니다: ${missing.join(', ')}. '
      '해당 경로에 직접 작성한 타입을 먼저 추가하세요.',
    );
  }
}

/// part 선언에 따라 build_runner가 만들 JSON 변환 파일까지 포함
Set<String> generatedPaths(Map<String, String> sources) {
  final result = sources.keys.toSet();
  for (final entry in sources.entries) {
    for (final part in RegExp(
      r"^part '([^']+\.g\.dart)';$",
      multiLine: true,
    ).allMatches(entry.value)) {
      result.add(p.posix.join(p.posix.dirname(entry.key), part[1]));
    }
  }
  return result;
}

Future<String> _downloadSchema(String url) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close().timeout(const Duration(seconds: 30));
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('명세 다운로드 실패: HTTP ${response.statusCode}');
    }
    return await utf8.decoder
        .bind(response)
        .join()
        .timeout(const Duration(seconds: 30));
  } finally {
    client.close(force: true);
  }
}

void _writeFiles(String root, Map<String, String> files) {
  for (final entry in files.entries) {
    final file = _managedFile(root, entry.key);
    file.parent.createSync(recursive: true);
    if (!file.existsSync() || file.readAsStringSync() != entry.value) {
      file.writeAsStringSync(entry.value);
    }
  }
}

void _ensureGenerated(
  String root,
  Iterable<String> paths,
  Map<String, String> previousHeaders,
) {
  for (final path in paths) {
    final file = _managedFile(root, path);
    if (!file.existsSync()) continue;
    final source = file.readAsStringSync();
    final previousHeader = previousHeaders[path];
    if (!source.contains('GENERATED CODE - DO NOT MODIFY BY HAND') &&
        (previousHeader == null ||
            !source.split('\n').contains(previousHeader))) {
      throw StateError('직접 작성한 파일을 덮어쓸 수 없습니다: $path');
    }
  }
}

File _managedFile(String root, String path) {
  final normalized = p.posix.normalize(path);
  // generated/는 이전 생성 파일 정리를 위해서만 허용
  final allowed = RegExp(
    r'^lib/features/[a-z][a-z0-9_]*/data_source/remote/(?:models|enums)/(?:generated/)?[^/]+\.dart$',
  ).hasMatch(normalized);
  if (normalized != path || !allowed) {
    throw StateError('생성 파일 경로가 허용 범위를 벗어납니다: $path');
  }
  return File(p.join(root, path));
}
