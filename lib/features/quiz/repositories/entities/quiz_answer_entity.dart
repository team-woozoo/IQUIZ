import 'package:iquiz/features/quiz/data_source/remote/models/quiz_answer_model.dart';

final class QuizAnswerEntity {
  const QuizAnswerEntity({required this.questionId, required this.optionId});

  factory QuizAnswerEntity.fromModel(QuizAnswerModel model) =>
      QuizAnswerEntity(questionId: model.questionId, optionId: model.optionId);

  final int questionId;
  final int optionId;

  /// 유효한 문제와 보기로 구성된 중복 없는 답안 목록
  static bool isValidSelection(List<QuizAnswerEntity> answers) =>
      answers.isNotEmpty &&
      answers.every((answer) => answer.questionId > 0 && answer.optionId > 0) &&
      answers.map((answer) => answer.questionId).toSet().length ==
          answers.length;
}
