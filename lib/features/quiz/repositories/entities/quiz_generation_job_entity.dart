import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_job_status.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/quiz_generation_job_model.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_generation_status.enum.dart';

final class QuizGenerationJobEntity {
  const QuizGenerationJobEntity({
    required this.jobId,
    required this.status,
    this.quizId,
    this.error,
  });

  factory QuizGenerationJobEntity.fromModel(QuizGenerationJobModel model) {
    final appStatus = switch (model.status) {
      QuizJobStatus.pending => QuizGenerationStatus.pending,
      QuizJobStatus.processing => QuizGenerationStatus.processing,
      QuizJobStatus.done => QuizGenerationStatus.done,
      QuizJobStatus.failed => QuizGenerationStatus.failed,
      QuizJobStatus.$unknown => throw const FormatException(
        '알 수 없는 퀴즈 생성 상태입니다.',
      ),
    };
    if (appStatus == QuizGenerationStatus.done && model.quizId == null) {
      throw const FormatException('완료된 작업 응답에 quizId가 없습니다.');
    }
    return QuizGenerationJobEntity(
      jobId: model.jobId,
      status: appStatus,
      quizId: model.quizId,
      error: appStatus == QuizGenerationStatus.failed
          ? CustomException.fromJson({
              'code': model.errorCode ?? 'GENERATION_FAILED',
              'detail': model.errorCode == 'NO_VALID_QUESTIONS'
                  ? '생성된 문제 중 유효한 문제가 없습니다.'
                  : '퀴즈 생성에 실패했습니다. 다시 시도해 주세요.',
            })
          : null,
    );
  }

  final int jobId;
  final QuizGenerationStatus status;
  final int? quizId;
  final Exception? error;
}
