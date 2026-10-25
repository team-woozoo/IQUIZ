import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_job_status.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/quiz_generation_options_model.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/quiz_generation_job_model.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_job_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_options_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_difficulty.enum.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_format.enum.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_generation_status.enum.dart';

extension QuizGenerationOptionsMapper on QuizGenerationOptionsEntity {
  QuizGenerationOptionsModel toRequest() => QuizGenerationOptionsModel(
    format: switch (format) {
      QuizFormat.multipleChoice => .multipleChoice,
      QuizFormat.ox => .ox,
    },
    difficulty: switch (difficulty) {
      QuizDifficulty.easy => .easy,
      QuizDifficulty.normal => .normal,
      QuizDifficulty.hard => .hard,
    },
  );
}

extension QuizGenerationJobMapper on QuizGenerationJobModel {
  QuizGenerationJobEntity toEntity() {
    final appStatus = switch (status) {
      QuizJobStatus.pending => QuizGenerationStatus.pending,
      QuizJobStatus.processing => QuizGenerationStatus.processing,
      QuizJobStatus.done => QuizGenerationStatus.done,
      QuizJobStatus.failed => QuizGenerationStatus.failed,
      QuizJobStatus.$unknown => throw const FormatException(
        '알 수 없는 퀴즈 생성 상태입니다.',
      ),
    };
    if (appStatus == QuizGenerationStatus.done && quizId == null) {
      throw const FormatException('완료된 작업 응답에 quizId가 없습니다.');
    }
    return QuizGenerationJobEntity(
      jobId: jobId,
      status: appStatus,
      quizId: quizId,
      error: appStatus == QuizGenerationStatus.failed
          ? CustomException.fromJson({
              'code': errorCode ?? 'GENERATION_FAILED',
              'detail': errorCode == 'NO_VALID_QUESTIONS'
                  ? '생성된 문제 중 유효한 문제가 없습니다.'
                  : '퀴즈 생성에 실패했습니다. 다시 시도해 주세요.',
            })
          : null,
    );
  }
}
