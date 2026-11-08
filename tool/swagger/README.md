# Swagger 모델 생성과 Entity 변환

`dart run tool/generate_swagger_models.dart`로 로컬 `tool/openapi.json`에서 모델을 생성합니다.
`--refresh`를 붙이면 `SWAGGER_SCHEMA_URL` 또는 설정의 `schemaUrl`에서 명세를 갱신합니다.

API 통신에는 Model을 사용합니다. 각 Model은 `fromJson`과 `toJson`을 모두 가지며,
중첩 Model과 목록도 `explicitToJson: true`로 JSON Map까지 변환합니다.
데이터 구조가 같은 요청·응답은 같은 Model을 사용하고, 필드가 다른 구조는 별도 Model로 유지합니다.
서버 JSON 필드명과 enum 값은 그대로 유지합니다.

응답을 도메인 객체로 변환할 때는 `QuizEntity.fromModel(model)`처럼 Entity의 factory를 사용합니다.
검증, 기본값 처리, 정렬은 해당 Entity에서 수행하며 별도 mapper는 사용하지 않습니다.
화면과 UseCase는 기존처럼 Entity를 사용하고 Repository가 변환을 연결합니다.

요청 Model에 `fromEntity`가 필요하면 `tool/swagger_models.json`의 모델 등록에 `entity`를 지정합니다.
다음 설정은 `QuizAnswerModel.fromEntity(QuizAnswerEntity entity)`를 생성합니다.

```json
"AnswerRequest": {
  "enabled": true,
  "directory": "lib/features/quiz/data_source/remote/models",
  "fileName": "quiz_answer_model.dart",
  "typeName": "QuizAnswerModel",
  "description": "퀴즈 제출 답안",
  "entity": {
    "typeName": "QuizAnswerEntity",
    "import": "package:iquiz/features/quiz/repositories/entities/quiz_answer_entity.dart"
  }
}
```

기본값은 각 필드를 `entity.필드명`으로 복사합니다.
이름이나 타입 변환이 필요하면 `entity.fields`에 필드별 Dart 식을 지정합니다.
예를 들어 생성 옵션의 enum 변환은 다음과 같습니다.

```json
"fields": {
  "format": "QuizGenerationFormat.values.byName(entity.format.name)",
  "difficulty": "QuizGenerationDifficulty.values.byName(entity.difficulty.name)"
}
```

사용 예:

```dart
final request = QuizGenerationOptionsModel.fromEntity(options);
final result = await remote.getJobIdByOptions(
  materialId: materialId,
  options: request,
);

final model = await remote.getQuiz(quizId: quizId);
final quiz = QuizEntity.fromModel(model);
```

생성된 Model 파일을 직접 수정하지 말고 `entity` 설정을 변경하세요.
`fromEntity`는 매번 동일하게 생성되고, 직접 작성하는 Entity의 `fromModel`은 재생성 대상이 아닙니다.
`enabled: false`의 수동 모델·enum 보존 규칙도 유지합니다.
