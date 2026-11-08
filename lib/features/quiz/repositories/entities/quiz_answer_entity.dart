import 'package:iquiz/features/quiz/data_source/remote/models/quiz_answer_model.dart';

final class QuizAnswerEntity {
  const QuizAnswerEntity({required this.questionId, required this.optionId});

  factory QuizAnswerEntity.fromModel(QuizAnswerModel model) =>
      QuizAnswerEntity(questionId: model.questionId, optionId: model.optionId);

  final int questionId;
  final int optionId;
}
