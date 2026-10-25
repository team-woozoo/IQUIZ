import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_submission_entity.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository.dart';

final class SubmitWrongAnswerReviewUseCase {
  SubmitWrongAnswerReviewUseCase(this.repository);

  final QuizRepository repository;
  bool _submitting = false;

  /// 응답 유실 시 자동 재제출하지 않음. 서버가 같은 답도 별도 기록
  Future<Result<QuizSubmissionEntity>> call({
    required List<QuizAnswerEntity> answers,
  }) async {
    // 대기 중 원본 목록이 바뀌어도 검증·요청에 사용할 답안은 동일하게 유지
    final snapshot = List<QuizAnswerEntity>.unmodifiable(answers);
    if (snapshot.isEmpty ||
        snapshot.any(
          (answer) => answer.questionId <= 0 || answer.optionId <= 0,
        ) ||
        snapshot.map((answer) => answer.questionId).toSet().length !=
            snapshot.length) {
      return Result.failure(const FormatException('복습할 문제마다 답안을 하나씩 선택해 주세요.'));
    }
    if (_submitting) {
      return Result.failure(const FormatException('복습 답안을 제출 중입니다.'));
    }
    _submitting = true;
    try {
      return await repository.submitWrongAnswerReview(answers: snapshot);
    } finally {
      _submitting = false;
    }
  }
}
