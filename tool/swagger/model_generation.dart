import 'dart:convert';

import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:swagger_parser/swagger_parser.dart';

/// 등록된 모델·enum만 명시된 폴더와 파일명으로 생성
final class ModelGenerationPlan {
  ModelGenerationPlan(String source, Map<String, dynamic> config) {
    final configuredModels = config['models'];
    if (configuredModels is! Map<String, dynamic>) {
      throw const FormatException(
        'tool/swagger_models.json에 models 설정이 필요합니다.',
      );
    }
    final registrations = <String, dynamic>{};
    final typeNames = <String, String>{};
    for (final entry in configuredModels.entries) {
      final value = entry.value;
      if (value == false) {
        skippedDisabled.add(entry.key);
        continue;
      }
      if (value is! Map<String, dynamic>) {
        throw FormatException(
          '${entry.key}: false 또는 directory와 fileName을 지정한 객체를 사용하세요.',
        );
      }
      if (value.containsKey('enabled') && value['enabled'] is! bool) {
        throw FormatException('${entry.key}: enabled는 true 또는 false여야 합니다.');
      }
      if (value.containsKey('typeName')) {
        final typeName = value['typeName'];
        if (typeName is! String ||
            !RegExp(r'^[A-Z][a-zA-Z0-9]*$').hasMatch(typeName) ||
            const {
              'String',
              'Object',
              'List',
              'Map',
              'Set',
              'DateTime',
              'Enum',
            }.contains(typeName)) {
          throw FormatException(
            '${entry.key}: typeName은 유효한 PascalCase 타입명이어야 합니다.',
          );
        }
        typeNames[entry.key] = typeName;
      }
      if (value['enabled'] == false) {
        skippedDisabled.add(entry.key);
        if (value.containsKey('directory') || value.containsKey('fileName')) {
          final destination = _destination(entry.key, value);
          if (externalDestinations.containsValue(destination)) {
            throw FormatException('중복된 모델 출력 파일: $destination');
          }
          externalDestinations[entry.key] = destination;
          preservedPaths.addAll({
            destination,
            '${p.posix.withoutExtension(destination)}.g.dart',
          });
        }
        continue;
      }
      registrations[entry.key] = value;
    }
    if (registrations.isEmpty) return;

    final document = jsonDecode(source) as Map<String, dynamic>;
    final paths = document['paths'] as Map<String, dynamic>? ?? {};
    const methods = {
      'get',
      'post',
      'put',
      'patch',
      'delete',
      'head',
      'options',
      'trace',
    };
    // 204·205·HEAD는 명세에 content가 잘못 들어 있어도 응답 모델로 사용하지 않음
    for (final path in paths.values) {
      for (final method in (path as Map<String, dynamic>).entries) {
        if (!methods.contains(method.key)) continue;
        final operation = method.value as Map<String, dynamic>;
        final responses = operation['responses'] as Map<String, dynamic>? ?? {};
        for (final response in responses.entries) {
          if (method.key == 'head' ||
              response.key == '204' ||
              response.key == '205') {
            responses[response.key] = {'description': 'No Content'};
          }
        }
      }
    }
    final normalizedSource = jsonEncode(document);

    resetUniqueNameCounters();
    final allParser = OpenApiParser(
      ParserConfig(normalizedSource, isJson: true),
    );
    allParser.parseRestClients();
    final allModels = allParser.parseDataClasses();
    final typesByName = {for (final model in allModels) model.name: model};
    final knownNames = allModels.map((model) => model.name).toSet();
    final unknown = registrations.keys.toSet().difference(knownNames);
    if (unknown.isNotEmpty) {
      throw FormatException('Swagger에 없는 모델·enum 등록: ${unknown.join(', ')}');
    }
    final ownersByTypeName = <String, String>{};
    for (final model in allModels) {
      final typeName = typeNames[model.name] ?? model.name;
      final owner = ownersByTypeName[typeName];
      if (owner != null && owner != model.name) {
        throw FormatException('Dart 타입명 중복: $owner, ${model.name} → $typeName');
      }
      ownersByTypeName[typeName] = model.name;
    }

    UniversalDataClass renamed(UniversalDataClass model) =>
        _renameModel(model, typeNames);

    resetUniqueNameCounters();
    final parser = OpenApiParser(
      ParserConfig(
        normalizedSource,
        isJson: true,
        // 실제 요청·응답에서 사용하는 타입만 유지. 미사용 components 제외
        includePaths: paths.keys.toList(),
      ),
    );
    parser.parseRestClients();
    final activeModels = parser.parseDataClasses();
    final eligibleModels = activeModels
        .where((model) => !_isEmpty(model))
        .toList();
    final eligibleNames = eligibleModels.map((model) => model.name).toSet();
    skippedUnregistered.addAll(
      eligibleNames
          .difference(registrations.keys.toSet())
          .difference(skippedDisabled),
    );
    skippedEmpty.addAll(registrations.keys.toSet().difference(eligibleNames));

    const generatorConfig = GeneratorConfig(
      name: 'iquiz_models',
      outputDirectory: 'lib/features',
      rootClient: false,
      exportFile: false,
      markFilesAsGenerated: true,
    );
    final fill = FillController(
      config: generatorConfig,
      info: parser.openApiInfo,
    );
    final originalNames = {
      for (final model in allModels)
        fill.fillDtoContent(renamed(model)).name: model.name,
    };
    final selected = eligibleModels
        .where((model) => registrations.containsKey(model.name))
        .toList();
    final occupiedPaths = externalDestinations.values.toSet();
    final destinationsByName = <String, String>{};
    final externalImports = <String, String>{};
    for (final model in allModels) {
      final destination = externalDestinations[model.name];
      if (destination == null) continue;
      _validateSuffix(model.name, destination, model);
      externalImports[fill.fillDtoContent(renamed(model)).name] = destination;
    }
    // 빈 응답도 설정은 검증하되 파일 생성은 제외
    for (final registration in registrations.entries) {
      if (registration.value is! Map<String, dynamic>) {
        throw FormatException(
          '${registration.key}: directory와 fileName을 지정하세요.',
        );
      }
      final value = registration.value as Map<String, dynamic>;
      final destination = _destination(registration.key, value);
      _validateSuffix(
        registration.key,
        destination,
        typesByName[registration.key]!,
      );
      if (!occupiedPaths.add(destination)) {
        throw FormatException('중복된 모델 출력 파일: $destination');
      }
      destinationsByName[registration.key] = destination;
    }
    for (final model in selected) {
      final destination = destinationsByName[model.name]!;
      modelDestinations[fill.fillDtoContent(renamed(model)).name] = destination;
      final feature = destination.split('/')[2];
      outputDirectories
          .putIfAbsent(feature, () => <String>{})
          .add(p.posix.dirname(destination));
      featureCounts.update(feature, (count) => count + 1, ifAbsent: () => 1);
    }

    final formatter = DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    );
    final files = Generator(
      generatorConfig,
      info: parser.openApiInfo,
      dataClasses: selected.map(renamed).toList(),
      restClients: const [],
    ).generateContent();
    for (final file in files) {
      final destination = modelDestinations[file.name]!;
      var rewritten = file.content.replaceAllMapped(
        RegExp(r"^(import|export) '([^']+)';$", multiLine: true),
        (match) {
          final uri = match[2]!;
          if (uri.startsWith('package:') || uri.startsWith('dart:')) {
            return match[0]!;
          }
          final dependency = p.posix.normalize(
            p.posix.join(p.posix.dirname(file.name), uri),
          );
          final external = externalImports[dependency];
          final target = modelDestinations[dependency] ?? external;
          if (target == null) {
            final name = originalNames[dependency] ?? dependency;
            if (skippedDisabled.contains(name)) {
              throw FormatException(
                '${originalNames[file.name]}에서 참조하는 $name 모델·enum이 '
                'false로 비활성화되어 있고 수동 파일 경로가 없습니다. '
                'enabled: false와 directory, fileName을 지정해 직접 작성한 '
                '타입을 연결하거나 참조 타입을 활성화하세요.',
              );
            }
            throw FormatException(
              '${originalNames[file.name]}에서 참조하는 $name 모델·enum이 '
              '미등록이거나 비어 있습니다. models 설정을 확인하세요. 자동 생성하지 않습니다.',
            );
          }
          if (external != null) requiredExternalPaths.add(external);
          final rewrittenUri =
              p.posix.dirname(target) == p.posix.dirname(destination)
              ? p.posix.basename(target)
              : 'package:iquiz/${target.substring('lib/'.length)}';
          return "${match[1]} '$rewrittenUri';";
        },
      );
      // 파일명을 변경해도 JSON 변환 part가 같은 이름으로 생성되도록 연결
      final helperName =
          '${p.posix.basenameWithoutExtension(destination)}.g.dart';
      rewritten = rewritten.replaceAllMapped(
        RegExp(r"^part '[^']+\.g\.dart';$", multiLine: true),
        (_) => "part '$helperName';",
      );
      final registration =
          registrations[originalNames[file.name]] as Map<String, dynamic>;
      final description =
          registration['description'] as String? ??
          '${typeNames[originalNames[file.name]] ?? originalNames[file.name]} API 데이터 타입.';
      featureFiles[destination] = formatter.format(
        _withFileDescription(rewritten, description),
      );
    }

    final exports = config['exports'] as Map<String, dynamic>? ?? {};
    for (final entry in exports.entries) {
      final fileName = entry.value;
      if (fileName is! String) {
        throw const FormatException('exports 파일명을 지정하세요.');
      }
      _validateDestination(entry.key, fileName);
      final destination = '${entry.key}/$fileName';
      if (occupiedPaths.contains(destination)) {
        throw FormatException('모델과 export 파일의 경로가 같습니다: $destination');
      }
      final names =
          modelDestinations.values
              .where((file) => p.posix.dirname(file) == entry.key)
              .map(p.posix.basename)
              .toList()
            ..sort();
      if (names.isEmpty) continue;
      final exportDescriptions =
          config['exportDescriptions'] as Map<String, dynamic>? ?? {};
      final description =
          exportDescriptions[entry.key] as String? ?? 'API 모델을 한곳에서 내보내는 파일.';
      featureFiles[destination] = formatter.format(
        _withFileDescription(
          names.map((name) => "export '$name';").join('\n'),
          description,
        ),
      );
    }
  }

  static String _withFileDescription(String source, String description) {
    final body = source
        .split('\n')
        .where((line) => !line.trimLeft().startsWith('//'))
        .join('\n')
        .trim();
    final summary = description.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
    final declaration = RegExp(
      r'^(?:@|(?:(?:abstract|base|final|interface|sealed|mixin)\s+)*(?:class|enum|typedef)\s)',
      multiLine: true,
    ).firstMatch(body);
    if (declaration == null) return '/// $summary\nlibrary;\n\n$body\n';
    return '${body.substring(0, declaration.start)}///\n/// $summary\n///\n'
        '${body.substring(declaration.start)}\n';
  }

  static bool _isEmpty(UniversalDataClass model) =>
      model is UniversalComponentClass &&
      model.parameters.isEmpty &&
      model.discriminator == null &&
      (model.undiscriminatedUnionVariants?.isEmpty ?? true) &&
      !model.typeDef;

  /// 파싱된 타입과 참조만 변경. JSON 키·enum 값·설명은 원문을 유지
  static UniversalDataClass _renameModel(
    UniversalDataClass model,
    Map<String, String> names,
  ) {
    String rename(String name) => names[name] ?? name;
    UniversalType renameField(UniversalType field) =>
        field.copyWith(type: rename(field.type));
    Set<UniversalType> renameFields(Set<UniversalType> fields) =>
        fields.map(renameField).toSet();
    return switch (model) {
      UniversalEnumClass() => UniversalEnumClass(
        name: rename(model.name),
        originalName: model.originalName,
        type: model.type,
        items: model.items,
        defaultValue: model.defaultValue,
        description: model.description,
      ),
      UniversalComponentClass() => model.copyWith(
        name: rename(model.name),
        imports: model.imports.map(rename).toSet(),
        parameters: renameFields(model.parameters),
        allOf: model.allOf == null
            ? null
            : (
                refs: model.allOf!.refs.map(rename).toSet(),
                properties: renameFields(model.allOf!.properties),
              ),
        discriminator: model.discriminator == null
            ? null
            : (
                propertyName: model.discriminator!.propertyName,
                discriminatorValueToRefMapping: model
                    .discriminator!
                    .discriminatorValueToRefMapping
                    .map((value, ref) => MapEntry(value, rename(ref))),
                refProperties: model.discriminator!.refProperties.map(
                  (ref, fields) => MapEntry(rename(ref), renameFields(fields)),
                ),
              ),
        discriminatorValue: model.discriminatorValue == null
            ? null
            : (
                propertyValue: model.discriminatorValue!.propertyValue,
                parentClass: rename(model.discriminatorValue!.parentClass),
              ),
        undiscriminatedUnionVariants: model.undiscriminatedUnionVariants?.map(
          (ref, fields) => MapEntry(rename(ref), renameFields(fields)),
        ),
      ),
    };
  }

  static String _destination(String name, Map<String, dynamic> value) {
    final directory = value['directory'];
    final fileName = value['fileName'];
    if (directory is! String || fileName is! String) {
      throw FormatException('$name: directory와 fileName을 모두 지정하세요.');
    }
    _validateDestination(directory, fileName);
    if (!fileName.endsWith('_model.dart') &&
        !fileName.endsWith('_enum.dart') &&
        !fileName.endsWith('.enum.dart')) {
      throw FormatException('$name: 파일명은 _model.dart 또는 .enum.dart로 끝나야 합니다.');
    }
    return '$directory/$fileName';
  }

  static void _validateSuffix(
    String name,
    String destination,
    UniversalDataClass model,
  ) {
    final valid = model is UniversalEnumClass
        ? destination.endsWith('.enum.dart') ||
              destination.endsWith('_enum.dart')
        : destination.endsWith('_model.dart');
    if (!valid) {
      throw FormatException(
        '$name: 모델은 _model.dart, enum은 .enum.dart로 끝나야 합니다.',
      );
    }
  }

  static void _validateDestination(String directory, String fileName) {
    if (!RegExp(
          r'^lib/features/[a-z][a-z0-9_]*/data_source/remote/(?:models|enums)$',
        ).hasMatch(directory) ||
        !RegExp(r'^[a-z][a-z0-9_]*(?:\.[a-z][a-z0-9_]*)*\.dart$')
            .hasMatch(fileName) ||
        fileName.endsWith('.g.dart')) {
      throw FormatException('허용되지 않은 모델 출력 경로: $directory/$fileName');
    }
  }

  final featureFiles = <String, String>{};
  final modelDestinations = <String, String>{};

  /// enabled: false에 경로가 있는 타입은 수동 구현만 import
  final externalDestinations = <String, String>{};
  final requiredExternalPaths = <String>{};
  final preservedPaths = <String>{};
  final outputDirectories = <String, Set<String>>{};
  final featureCounts = <String, int>{};
  final skippedUnregistered = <String>{};
  final skippedEmpty = <String>{};
  final skippedDisabled = <String>{};

  /// 수동 경로는 보존하며 그 밖의 이전 생성 파일을 정리
  bool get shouldReconcileFiles =>
      featureFiles.isNotEmpty || skippedDisabled.isNotEmpty;
}
