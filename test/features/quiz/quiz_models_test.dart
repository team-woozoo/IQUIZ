import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/question_cognitive_type.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_difficulty_level.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_format_type.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_generation_difficulty.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_generation_format.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_job_status.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/models.dart';

void main() {
  test('생성 옵션의 새 타입명은 기존 서버 필드와 enum 문자열을 유지한다', () {
    const options = QuizGenerationOptionsModel(
      format: QuizGenerationFormat.multipleChoice,
      difficulty: QuizGenerationDifficulty.normal,
    );
    expect(options.toJson(), {
      'format': 'MULTIPLE_CHOICE',
      'difficulty': 'NORMAL',
    });
  });

  test('중첩 퀴즈 모델의 JSON 변환은 기존 필드와 nullable 값을 유지한다', () {
    final json = <String, Object?>{
      'quizId': 1,
      'materialId': null,
      'format': 'OX',
      'difficulty': 'HARD',
      'questions': [
        {
          'questionId': 2,
          'orderNo': 1,
          'content': '문제',
          'cognitiveType': 'UNDERSTAND',
          'conceptName': '개념',
          'explanation': '해설',
          'sourceQuote': '근거',
          'sourcePageNo': null,
          'options': [
            {'optionId': 3, 'orderNo': 1, 'content': 'O', 'isCorrect': true},
            {'optionId': 4, 'orderNo': 2, 'content': 'X', 'isCorrect': false},
          ],
        },
      ],
    };
    final model = QuizModel.fromJson(json);
    expect(model.format, QuizFormatType.ox);
    expect(model.difficulty, QuizDifficultyLevel.hard);
    expect(model.questions.single, isA<QuizQuestionModel>());
    expect(
      model.questions.single.cognitiveType,
      QuestionCognitiveType.understand,
    );
    expect(model.questions.single.options.first, isA<QuizOptionModel>());
    expect(jsonDecode(jsonEncode(model)), json);
  });

  test('수동 작업 상태 enum과 알 수 없는 서버 값 처리를 유지한다', () {
    final job = QuizGenerationJobModel.fromJson({
      'jobId': 1,
      'status': 'DONE',
      'quizId': 2,
      'errorCode': null,
    });
    expect(job.status, QuizJobStatus.done);
    expect(job.toJson(), {
      'jobId': 1,
      'status': 'DONE',
      'quizId': 2,
      'errorCode': null,
    });
    expect(
      QuizGenerationFormat.fromJson('NEW_FORMAT'),
      QuizGenerationFormat.$unknown,
    );
    expect(
      QuizGenerationDifficulty.fromJson('NEW_LEVEL'),
      QuizGenerationDifficulty.$unknown,
    );
    expect(QuizFormatType.fromJson('NEW_FORMAT'), QuizFormatType.$unknown);
    expect(
      QuizDifficultyLevel.fromJson('NEW_LEVEL'),
      QuizDifficultyLevel.$unknown,
    );
    expect(
      QuestionCognitiveType.fromJson('NEW_TYPE'),
      QuestionCognitiveType.$unknown,
    );
    expect(QuizJobStatus.fromJson('NEW_STATUS'), QuizJobStatus.$unknown);
  });
}
