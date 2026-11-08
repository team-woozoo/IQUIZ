import 'package:iquiz/features/quiz/data_source/remote/models/quiz_submit_result_model.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_question_result_entity.dart';

final class QuizSubmissionEntity {
  const QuizSubmissionEntity({
    required this.submissionId,
    required this.correctCount,
    required this.totalCount,
    required this.results,
  });

  factory QuizSubmissionEntity.fromModel(QuizSubmitResultModel model) {
    if (model.submissionId <= 0 ||
        model.totalCount <= 0 ||
        model.correctCount < 0 ||
        model.correctCount > model.totalCount ||
        model.results.length != model.totalCount ||
        model.results.any((result) => result.questionId <= 0) ||
        model.results.map((result) => result.questionId).toSet().length !=
            model.totalCount ||
        model.results.where((result) => result.correct).length !=
            model.correctCount) {
      throw const FormatException('서버 채점 결과가 올바르지 않습니다.');
    }
    return QuizSubmissionEntity(
      submissionId: model.submissionId,
      correctCount: model.correctCount,
      totalCount: model.totalCount,
      results: List.unmodifiable(
        model.results.map(QuizQuestionResultEntity.fromModel),
      ),
    );
  }

  final int submissionId;
  final int correctCount;
  final int totalCount;
  final List<QuizQuestionResultEntity> results;

  int get correctRate =>
      totalCount == 0 ? 0 : (correctCount / totalCount * 100).round();
}
