import 'package:iquiz/features/quiz/data_source/remote/models/quiz_question_result_model.dart';

final class QuizQuestionResultEntity {
  const QuizQuestionResultEntity({
    required this.questionId,
    required this.correct,
  });

  factory QuizQuestionResultEntity.fromModel(QuizQuestionResultModel model) =>
      QuizQuestionResultEntity(
        questionId: model.questionId,
        correct: model.correct,
      );

  final int questionId;
  final bool correct;
}
