import 'package:iquiz/features/quiz/repositories/entities/quiz_question_result_entity.dart';

final class QuizSubmissionEntity {
  const QuizSubmissionEntity({
    required this.submissionId,
    required this.correctCount,
    required this.totalCount,
    required this.results,
  });

  final int submissionId;
  final int correctCount;
  final int totalCount;
  final List<QuizQuestionResultEntity> results;

  int get correctRate =>
      totalCount == 0 ? 0 : (correctCount / totalCount * 100).round();
}
