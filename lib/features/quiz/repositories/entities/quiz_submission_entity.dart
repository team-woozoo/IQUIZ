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
    final validTotals =
        model.submissionId > 0 &&
        model.totalCount > 0 &&
        model.correctCount >= 0 &&
        model.correctCount <= model.totalCount;
    final questionIds = model.results
        .map((result) => result.questionId)
        .toList();
    final validResults =
        questionIds.length == model.totalCount &&
        questionIds.every((id) => id > 0) &&
        questionIds.toSet().length == model.totalCount &&
        model.results.where((result) => result.correct).length ==
            model.correctCount;

    if (!validTotals || !validResults) {
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

  /// 응답 순서와 관계없이 요청한 문제들이 채점됐는지 확인
  bool matchesQuestions(Iterable<int> questionIds) {
    final expectedIds = questionIds.toSet();
    return totalCount == expectedIds.length &&
        results.length == expectedIds.length &&
        results.every((result) => expectedIds.contains(result.questionId)) &&
        results.map((result) => result.questionId).toSet().length ==
            expectedIds.length;
  }

  int get correctRate =>
      totalCount == 0 ? 0 : (correctCount / totalCount * 100).round();
}
