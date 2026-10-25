import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../tool/generate_swagger_models.dart'
    show generatedPaths, staleGeneratedPaths, validateExternalFiles;
import '../../tool/swagger/model_generation.dart';

const authPath = 'lib/features/auth/data_source/remote/models';
const quizPath = 'lib/features/quiz/data_source/remote/models';
const quizEnumPath = 'lib/features/quiz/data_source/remote/enums';

void main() {
  test('타입명을 바꿔도 중첩 목록·enum 참조와 서버 JSON 값은 유지한다', () {
    final source = _schema(
      schemas: {
        'QuizResponse': _object({
          'questions': {
            'type': 'array',
            'items': {r'$ref': '#/components/schemas/QuestionResponse'},
          },
          'status': {
            'type': 'string',
            'enum': ['QuestionResponse', 'DONE'],
          },
        }),
        'QuestionResponse': _object({
          'content': {'type': 'string'},
        }),
      },
      paths: {
        '/quiz': {'get': _operation('QuizResponse')},
      },
    );
    final config = _config({
      'QuizResponse': '$quizPath/quiz_model.dart',
      'QuestionResponse': '$quizPath/quiz_question_model.dart',
      'QuizResponseStatus': '$quizEnumPath/quiz_status.enum.dart',
    });
    final models = config['models'] as Map;
    (models['QuizResponse'] as Map)['typeName'] = 'QuizModel';
    (models['QuestionResponse'] as Map)['typeName'] = 'QuizQuestionModel';
    (models['QuizResponseStatus'] as Map)['typeName'] = 'QuizStatus';

    final plan = ModelGenerationPlan(source, config);
    final quiz = plan.featureFiles['$quizPath/quiz_model.dart']!;
    expect(quiz, contains('class QuizModel'));
    expect(quiz, contains('const QuizModel('));
    expect(quiz, contains('factory QuizModel.fromJson('));
    expect(quiz, contains(r'_$QuizModelFromJson(json)'));
    expect(quiz, contains('List<QuizQuestionModel>? questions'));
    expect(quiz, contains('QuizStatus? status'));
    expect(quiz, contains("import 'quiz_question_model.dart';"));
    expect(quiz, contains('enums/quiz_status.enum.dart'));
    expect(quiz, contains("part 'quiz_model.g.dart';"));
    expect(
      plan.featureFiles['$quizEnumPath/quiz_status.enum.dart'],
      allOf(
        contains('enum QuizStatus'),
        contains("@JsonValue('QuestionResponse')"),
      ),
    );
    expect(
      jsonDecode(source)['components']['schemas'],
      contains('QuizResponse'),
    );
  });

  test('수동 enum의 별도 타입명과 경로도 생성 모델에 연결한다', () {
    final source = _schema(
      schemas: {
        'JobResponse': _object({
          'status': {
            'type': 'string',
            'enum': ['PENDING', 'DONE'],
          },
        }),
      },
      paths: {
        '/jobs': {'get': _operation('JobResponse')},
      },
    );
    final config = _config({
      'JobResponse': '$quizPath/quiz_job_model.dart',
      'JobResponseStatus': '$quizEnumPath/quiz_job_status.enum.dart',
    });
    final models = config['models'] as Map;
    (models['JobResponse'] as Map)['typeName'] = 'QuizJobModel';
    (models['JobResponseStatus'] as Map).addAll(<String, dynamic>{
      'enabled': false,
      'typeName': 'QuizJobStatus',
    });
    final plan = ModelGenerationPlan(source, config);
    expect(
      plan.featureFiles['$quizPath/quiz_job_model.dart'],
      allOf(
        contains('QuizJobStatus? status'),
        contains('quiz_job_status.enum.dart'),
      ),
    );
    expect(plan.requiredExternalPaths, {
      '$quizEnumPath/quiz_job_status.enum.dart',
    });
    expect(
      plan.featureFiles,
      isNot(contains('$quizEnumPath/quiz_job_status.enum.dart')),
    );
  });

  test('잘못된 타입명과 다른 Swagger 타입과의 이름 충돌을 차단한다', () {
    for (final name in [
      '',
      'quiz-model',
      'quizModel',
      'String',
      1,
      null,
      'SharedResponse',
    ]) {
      final config = _config({'AuthResponse': '$authPath/auth_model.dart'});
      ((config['models'] as Map)['AuthResponse'] as Map)['typeName'] = name;
      expect(
        () => ModelGenerationPlan(_schema(), config),
        throwsFormatException,
      );
    }
    final config = _config({
      'AuthResponse': '$authPath/auth_model.dart',
      'SharedResponse': '$authPath/shared_model.dart',
    });
    for (final entry in (config['models'] as Map).values) {
      (entry as Map)['typeName'] = 'SameModel';
    }
    expect(() => ModelGenerationPlan(_schema(), config), throwsFormatException);
  });

  test('실제 명세는 미리 등록한 모델과 경로만 사용한다', () {
    final config = jsonDecode(
      File('tool/swagger_models.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final plan = ModelGenerationPlan(
      File('tool/openapi.json').readAsStringSync(),
      config,
    );
    final registrations = config['models'] as Map<String, dynamic>;
    final allowedPaths = <String>{};
    for (final registration in registrations.values) {
      if (registration == false) continue;
      final entry = registration as Map<String, dynamic>;
      if (entry['enabled'] == false) continue;
      allowedPaths.add('${entry['directory']}/${entry['fileName']}');
    }
    final exports = config['exports'] as Map<String, dynamic>? ?? {};
    allowedPaths.addAll(
      exports.entries.map((entry) => '${entry.key}/${entry.value}'),
    );
    for (final path in plan.featureFiles.keys) {
      expect(allowedPaths, contains(path));
    }
    expect(
      plan.featureFiles.keys.any((file) => file.contains('client')),
      isFalse,
    );
  });

  test('등록되지 않은 독립 모델은 생성하지 않는다', () {
    final plan = ModelGenerationPlan(
      _schema(),
      _config({
        'AuthResponse': '$authPath/auth_response_model.dart',
        'SharedResponse': '$authPath/shared_response_model.dart',
      }),
    );
    expect(plan.featureCounts, {'auth': 2});
    expect(plan.skippedUnregistered, contains('QuizResponse'));
    expect(
      plan.featureFiles.keys.any((file) => file.contains('/quiz/')),
      isFalse,
    );
  });

  test('enabled false인 모델은 파일, JSON part, export에서 제외한다', () {
    final config = _config({
      'AuthResponse': '$authPath/auth_response_model.dart',
      'SharedResponse': '$authPath/shared_response_model.dart',
    })..['exports'] = {authPath: 'models.dart'};
    ((config['models'] as Map)['AuthResponse'] as Map)['enabled'] = false;

    final plan = ModelGenerationPlan(_schema(), config);

    expect(plan.featureCounts, {'auth': 1});
    expect(plan.skippedDisabled, {'AuthResponse'});
    expect(plan.skippedUnregistered, isNot(contains('AuthResponse')));
    expect(
      generatedPaths(plan.featureFiles),
      isNot(contains('$authPath/auth_response_model.dart')),
    );
    expect(
      generatedPaths(plan.featureFiles),
      isNot(contains('$authPath/auth_response_model.g.dart')),
    );
    expect(
      plan.featureFiles['$authPath/models.dart'],
      isNot(contains('auth_response')),
    );
    expect(
      plan.featureFiles['$authPath/models.dart'],
      contains('shared_response'),
    );
  });

  test('타입 값 자체를 false로 지정해도 생성하지 않는다', () {
    final config = _config({
      'AuthResponse': '$authPath/auth_response_model.dart',
      'SharedResponse': '$authPath/shared_response_model.dart',
    });
    (config['models'] as Map)['QuizResponse'] = false;

    final plan = ModelGenerationPlan(_schema(), config);

    expect(plan.skippedDisabled, {'QuizResponse'});
    expect(plan.featureCounts, {'auth': 2});
    expect(
      plan.featureFiles.keys.any((path) => path.startsWith(quizPath)),
      isFalse,
    );
  });

  test('생성할 모델이 참조하는 타입을 false로 끄면 명확한 오류로 중단한다', () {
    final config = _config({
      'AuthResponse': '$authPath/auth_response_model.dart',
    });
    (config['models'] as Map)['SharedResponse'] = false;

    expect(
      () => ModelGenerationPlan(_schema(), config),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          allOf(
            contains('AuthResponse'),
            contains('SharedResponse'),
            contains('false'),
          ),
        ),
      ),
    );
  });

  test('enabled false인 enum은 수동 경로를 import하고 기존 파일을 보존한다', () {
    final source = _schema(
      schemas: {
        'QuizSettings': _object({
          'status': {
            'type': 'string',
            'enum': ['PENDING', 'DONE'],
          },
        }),
      },
      paths: {
        '/settings': {'get': _operation('QuizSettings')},
      },
    );
    final config = _config({
      'QuizSettings': '$quizPath/quiz_settings_model.dart',
      'QuizSettingsStatus': '$quizEnumPath/quiz_status_enum.dart',
    });
    ((config['models'] as Map)['QuizSettingsStatus'] as Map)['enabled'] = false;

    final plan = ModelGenerationPlan(source, config);
    const enumFile = '$quizEnumPath/quiz_status_enum.dart';
    expect(plan.featureFiles.keys, isNot(contains(enumFile)));
    expect(
      plan.featureFiles['$quizPath/quiz_settings_model.dart'],
      contains(
        "import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_status_enum.dart';",
      ),
    );
    expect(plan.requiredExternalPaths, {enumFile});
    expect(staleGeneratedPaths(plan, {enumFile}), isEmpty);
    final root = Directory.systemTemp.createTempSync('swagger-manual-enum-');
    addTearDown(() => root.deleteSync(recursive: true));
    expect(() => validateExternalFiles(root.path, plan), throwsStateError);
    final manual = File(p.join(root.path, enumFile));
    manual.parent.createSync(recursive: true);
    const manualSource = 'enum QuizSettingsStatus { pending, done }\n';
    manual.writeAsStringSync(manualSource);
    validateExternalFiles(root.path, plan);
    expect(manual.readAsStringSync(), manualSource);
  });

  test('수동 모델은 같은 폴더의 import와 JSON part 보존을 지원한다', () {
    final config = _config({
      'AuthResponse': '$authPath/auth_response_model.dart',
      'SharedResponse': '$authPath/custom_shared_model.dart',
    });
    ((config['models'] as Map)['SharedResponse'] as Map)['enabled'] = false;
    final plan = ModelGenerationPlan(_schema(), config);
    expect(
      plan.featureFiles['$authPath/auth_response_model.dart'],
      contains("import 'custom_shared_model.dart';"),
    );
    expect(plan.requiredExternalPaths, {'$authPath/custom_shared_model.dart'});
    expect(
      staleGeneratedPaths(plan, {
        '$authPath/custom_shared_model.dart',
        '$authPath/custom_shared_model.g.dart',
        '$authPath/old_model.dart',
      }),
      {'$authPath/old_model.dart'},
    );
  });

  test('전부 수동 관리여도 파일과 JSON part를 정리하지 않는다', () {
    final config = _config({
      'SharedResponse': '$authPath/shared_response_model.dart',
    });
    ((config['models'] as Map)['SharedResponse'] as Map)['enabled'] = false;
    final plan = ModelGenerationPlan(_schema(), config);
    expect(plan.featureFiles, isEmpty);
    expect(
      staleGeneratedPaths(plan, {
        '$authPath/shared_response_model.dart',
        '$authPath/shared_response_model.g.dart',
        '$authPath/models.dart',
      }),
      {'$authPath/models.dart'},
    );
  });

  test('수동 타입과 생성 타입의 경로 중복도 생성 전에 차단한다', () {
    final config = _config({
      'AuthResponse': '$authPath/auth_response_model.dart',
      'SharedResponse': '$authPath/auth_response_model.dart',
    });
    ((config['models'] as Map)['SharedResponse'] as Map)['enabled'] = false;
    expect(() => ModelGenerationPlan(_schema(), config), throwsFormatException);
  });

  test('비활성화된 항목은 경로가 없거나 명세에서 사라졌어도 무시한다', () {
    final config = _config({
      'SharedResponse': '$authPath/shared_response_model.dart',
    });
    (config['models'] as Map<String, dynamic>).addAll({
      'AuthResponse': {'enabled': false},
      'RemovedResponse': false,
    });

    final plan = ModelGenerationPlan(_schema(), config);

    expect(plan.skippedDisabled, {'AuthResponse', 'RemovedResponse'});
    expect(plan.featureCounts, {'auth': 1});
  });

  test('enabled는 boolean만 허용하고 true만 적어 경로를 생략할 수 없다', () {
    for (final value in [
      true,
      {'enabled': 'false'},
      {'enabled': null},
      {'enabled': true},
    ]) {
      expect(
        () => ModelGenerationPlan(_schema(), {
          'models': {'AuthResponse': value},
        }),
        throwsFormatException,
      );
    }
  });

  test('전부 false이면 이전 생성 파일을 정리하고 빈 설정은 보존한다', () {
    final previous = {
      '$authPath/auth_response_model.dart',
      '$authPath/auth_response_model.g.dart',
      '$authPath/models.dart',
    };
    final disabled = ModelGenerationPlan(_schema(), {
      'models': {
        'AuthResponse': false,
        'SharedResponse': {'enabled': false},
      },
      'exports': {authPath: 'models.dart'},
    });
    final empty = ModelGenerationPlan(_schema(), _config({}));

    expect(disabled.featureFiles, isEmpty);
    expect(disabled.shouldReconcileFiles, isTrue);
    expect(staleGeneratedPaths(disabled, previous), previous);
    expect(empty.shouldReconcileFiles, isFalse);
    expect(staleGeneratedPaths(empty, previous), isEmpty);
  });

  test('일부만 false로 바꾸면 그 모델과 JSON part만 정리 대상으로 남는다', () {
    final previous = {
      '$authPath/auth_response_model.dart',
      '$authPath/auth_response_model.g.dart',
      '$authPath/shared_response_model.dart',
      '$authPath/shared_response_model.g.dart',
      '$authPath/models.dart',
    };
    final config = _config({
      'SharedResponse': '$authPath/shared_response_model.dart',
    })..['exports'] = {authPath: 'models.dart'};
    (config['models'] as Map)['AuthResponse'] = false;

    final plan = ModelGenerationPlan(_schema(), config);

    expect(staleGeneratedPaths(plan, previous), {
      '$authPath/auth_response_model.dart',
      '$authPath/auth_response_model.g.dart',
    });
  });

  test('설정이 비어 있으면 모델과 export를 전혀 생성하지 않는다', () {
    final plan = ModelGenerationPlan(
      _schema(),
      _config({})..['exports'] = {authPath: 'models.dart'},
    );
    expect(plan.featureFiles, isEmpty);
    expect(generatedPaths(plan.featureFiles), isEmpty);
  });

  test('models 설정이 없으면 기존 태그별 자동 생성으로 돌아가지 않는다', () {
    expect(() => ModelGenerationPlan(_schema(), {}), throwsFormatException);
  });

  test('등록된 모델의 참조 타입이 미등록이면 임의 생성하지 않고 중단한다', () {
    expect(
      () => ModelGenerationPlan(
        _schema(),
        _config({'AuthResponse': '$authPath/auth_response_model.dart'}),
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('SharedResponse'),
        ),
      ),
    );
  });

  test('지정한 파일명으로 part와 기능 간 import까지 연결한다', () {
    final plan = ModelGenerationPlan(
      _schema(),
      _config({
        'SharedResponse': '$authPath/account_info_model.dart',
        'QuizResponse': '$quizPath/quiz_payload_model.dart',
      }),
    );
    final source = plan.featureFiles['$quizPath/quiz_payload_model.dart']!;
    expect(
      source,
      contains(
        "import 'package:iquiz/features/auth/data_source/remote/models/account_info_model.dart';",
      ),
    );
    expect(source, contains("part 'quiz_payload_model.g.dart';"));
    expect(source, contains('class QuizResponse'));
    expect(
      generatedPaths(plan.featureFiles),
      contains('$quizPath/quiz_payload_model.g.dart'),
    );
    expect(
      plan.featureFiles.keys.any((file) => file.endsWith('/models.dart')),
      isFalse,
    );
  });

  test('export 파일도 등록한 이름으로만 만든다', () {
    final config = _config({'SharedResponse': '$authPath/account_model.dart'})
      ..['exports'] = {authPath: 'auth_models.dart'};
    final plan = ModelGenerationPlan(_schema(), config);
    expect(
      plan.featureFiles['$authPath/auth_models.dart'],
      contains("export 'account_model.dart';"),
    );
    expect(plan.featureFiles.containsKey('$authPath/models.dart'), isFalse);
  });

  test('204는 잘못된 content가 있어도 응답 모델을 생성하지 않는다', () {
    final source = _schema(
      schemas: {
        'LogoutResponse': _object({
          'id': {'type': 'integer'},
        }),
      },
      paths: {
        '/logout': {'post': _operation('LogoutResponse', status: '204')},
      },
    );
    final plan = ModelGenerationPlan(
      source,
      _config({'LogoutResponse': '$authPath/logout_response_model.dart'}),
    );
    expect(plan.featureFiles, isEmpty);
    expect(plan.skippedEmpty, contains('LogoutResponse'));
  });

  test('빈 객체 응답과 미사용 스키마는 등록되어도 모델을 만들지 않는다', () {
    final source = _schema(
      schemas: {
        'EmptyResponse': _object({}),
        'UnusedResponse': _object({
          'id': {'type': 'integer'},
        }),
      },
      paths: {
        '/empty': {'get': _operation('EmptyResponse')},
      },
    );
    final plan = ModelGenerationPlan(
      source,
      _config({
        'EmptyResponse': '$authPath/empty_response_model.dart',
        'UnusedResponse': '$authPath/unused_response_model.dart',
      }),
    );
    expect(plan.featureFiles, isEmpty);
  });

  test('반환 본문이 없어도 필요한 요청 모델은 별도로 생성한다', () {
    final operation = _operation('InputRequest', status: '204')
      ..['requestBody'] = {
        'required': true,
        'content': {
          'application/json': {
            'schema': {r'$ref': '#/components/schemas/InputRequest'},
          },
        },
      };
    final source = _schema(
      schemas: {
        'InputRequest': _object({
          'email': {'type': 'string'},
        }),
      },
      paths: {
        '/submit': {'post': operation},
      },
    );
    final plan = ModelGenerationPlan(
      source,
      _config({'InputRequest': '$authPath/input_request_model.dart'}),
    );
    expect(plan.featureFiles, contains('$authPath/input_request_model.dart'));
  });

  test('ID 하나도 반환 데이터이므로 명시적으로 등록하면 모델을 만든다', () {
    final source = _schema(
      schemas: {
        'IdResponse': _object({
          'id': {'type': 'integer', 'format': 'int64'},
        }),
      },
      paths: {
        '/id': {'get': _operation('IdResponse')},
      },
    );
    final plan = ModelGenerationPlan(
      source,
      _config({'IdResponse': '$authPath/id_response_model.dart'}),
    );
    expect(
      plan.featureFiles['$authPath/id_response_model.dart'],
      contains('final int? id;'),
    );
  });

  test('폴더·파일명 미지정과 중복 경로를 허용하지 않는다', () {
    final config = _config({'SharedResponse': '$authPath/account_model.dart'});
    ((config['models'] as Map)['SharedResponse'] as Map).remove('fileName');
    expect(() => ModelGenerationPlan(_schema(), config), throwsFormatException);
    expect(
      () => ModelGenerationPlan(
        _schema(),
        _config({
          'SharedResponse': '$authPath/same_model.dart',
          'AuthResponse': '$authPath/same_model.dart',
        }),
      ),
      throwsFormatException,
    );
  });

  test('명세에 없는 등록 이름은 오타로 알려준다', () {
    expect(
      () => ModelGenerationPlan(
        _schema(),
        _config({'TypoResponse': '$authPath/typo_model.dart'}),
      ),
      throwsFormatException,
    );
  });

  test('모델은 _model, enum은 _enum 파일명으로 생성하고 잘못된 접미사는 거부한다', () {
    final source = _schema(
      schemas: {
        'QuizSettings': _object({
          'status': {
            'type': 'string',
            'enum': ['PENDING', 'DONE'],
          },
        }),
      },
      paths: {
        '/settings': {'get': _operation('QuizSettings')},
      },
    );
    final valid = _config({
      'QuizSettings': '$quizPath/quiz_settings_model.dart',
      'QuizSettingsStatus': '$quizPath/quiz_status_enum.dart',
    });
    final plan = ModelGenerationPlan(source, valid);
    expect(
      plan.featureFiles['$quizPath/quiz_settings_model.dart'],
      contains("import 'quiz_status_enum.dart';"),
    );
    expect(
      plan.featureFiles['$quizPath/quiz_status_enum.dart'],
      contains('enum QuizSettingsStatus'),
    );
    expect(
      generatedPaths(plan.featureFiles),
      contains('$quizPath/quiz_settings_model.g.dart'),
    );
    expect(
      generatedPaths(plan.featureFiles),
      isNot(contains('$quizPath/quiz_status_enum.g.dart')),
    );
    for (final invalid in [
      _config({
        'QuizSettings': '$quizPath/quiz_settings.dart',
        'QuizSettingsStatus': '$quizPath/quiz_status_enum.dart',
      }),
      _config({
        'QuizSettings': '$quizPath/quiz_settings_model.dart',
        'QuizSettingsStatus': '$quizPath/quiz_status_model.dart',
      }),
    ]) {
      expect(() => ModelGenerationPlan(source, invalid), throwsFormatException);
    }
  });

  test('출력 폴더 밖의 경로와 JSON 변환용 예약 파일명은 거부한다', () {
    for (final target in [
      'lib/shared/models/account_model.dart',
      '$authPath/account.g.dart',
      '$authPath/../account_model.dart',
    ]) {
      expect(
        () =>
            ModelGenerationPlan(_schema(), _config({'SharedResponse': target})),
        throwsFormatException,
      );
    }
  });

  test('같은 기능의 models와 enums 폴더를 나누고 import·export를 각각 연결한다', () {
    final source = _schema(
      schemas: {
        'QuizSettings': _object({
          'status': {
            'type': 'string',
            'enum': ['PENDING', 'DONE'],
          },
        }),
      },
      paths: {
        '/settings': {'get': _operation('QuizSettings')},
      },
    );
    final config = _config({
      'QuizSettings': '$quizPath/quiz_settings_model.dart',
      'QuizSettingsStatus': '$quizEnumPath/quiz_status_enum.dart',
    })..['exports'] = {quizPath: 'models.dart', quizEnumPath: 'enums.dart'};
    final plan = ModelGenerationPlan(source, config);
    expect(
      plan.featureFiles['$quizPath/quiz_settings_model.dart'],
      contains(
        "import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_status_enum.dart';",
      ),
    );
    expect(plan.featureFiles, contains('$quizEnumPath/quiz_status_enum.dart'));
    expect(
      plan.featureFiles.containsKey('$quizPath/quiz_status_enum.dart'),
      isFalse,
    );
    expect(
      plan.featureFiles['$quizPath/models.dart'],
      contains("export 'quiz_settings_model.dart';"),
    );
    expect(
      plan.featureFiles['$quizPath/models.dart'],
      isNot(contains('quiz_status_enum')),
    );
    expect(
      plan.featureFiles['$quizEnumPath/enums.dart'],
      contains("export 'quiz_status_enum.dart';"),
    );
    expect(plan.outputDirectories['quiz'], {quizPath, quizEnumPath});
    expect(
      generatedPaths(plan.featureFiles),
      isNot(contains('$quizEnumPath/quiz_status_enum.g.dart')),
    );
  });
}

Map<String, dynamic> _config(Map<String, String> models) => {
  'models': <String, dynamic>{
    for (final entry in models.entries)
      entry.key: <String, dynamic>{
        'directory': p.posix.dirname(entry.value),
        'fileName': p.posix.basename(entry.value),
      },
  },
};

Map<String, dynamic> _object(Map<String, dynamic> properties) => {
  'type': 'object',
  'properties': properties,
};

Map<String, dynamic> _operation(String response, {String status = '200'}) => {
  'responses': {
    status: {
      'description': 'Response',
      'content': {
        'application/json': {
          'schema': {r'$ref': '#/components/schemas/$response'},
        },
      },
    },
  },
};

String _schema({Map<String, dynamic>? schemas, Map<String, dynamic>? paths}) =>
    jsonEncode({
      'openapi': '3.1.0',
      'info': {'title': 'Registration test', 'version': '1.0'},
      'paths':
          paths ??
          {
            '/auth': {'get': _operation('AuthResponse')},
            '/quiz': {'get': _operation('QuizResponse')},
          },
      'components': {
        'schemas':
            schemas ??
            {
              'SharedResponse': _object({
                'id': {'type': 'integer', 'format': 'int64'},
              }),
              for (final name in ['AuthResponse', 'QuizResponse'])
                name: _object({
                  'shared': {r'$ref': '#/components/schemas/SharedResponse'},
                }),
            },
      },
    });
