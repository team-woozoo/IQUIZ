import 'package:iquiz/features/quiz/data_source/remote/models/quiz_option_model.dart';

final class QuizOptionEntity {
  const QuizOptionEntity({
    required this.optionId,
    required this.content,
    required this.isCorrect,
  });

  factory QuizOptionEntity.fromModel(QuizOptionModel model) => QuizOptionEntity(
    optionId: model.optionId,
    content: model.content,
    isCorrect: model.isCorrect,
  );

  final int optionId;
  final String content;
  final bool isCorrect;
}
