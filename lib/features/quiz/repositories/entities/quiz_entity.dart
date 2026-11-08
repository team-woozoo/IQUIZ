import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_difficulty_level.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_format_type.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/quiz_model.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_question_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_difficulty.enum.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_format.enum.dart';

final class QuizEntity {
  const QuizEntity({
    required this.quizId,
    required this.materialId,
    required this.format,
    required this.difficulty,
    required this.questions,
  });

  factory QuizEntity.fromModel(QuizModel model) {
    final orderedQuestions = [...model.questions]
      ..sort((a, b) => a.orderNo.compareTo(b.orderNo));
    if (orderedQuestions
            .map((question) => question.questionId)
            .toSet()
            .length !=
        orderedQuestions.length) {
      throw const FormatException('문제 정보가 올바르지 않습니다. 다시 불러와 주세요.');
    }
    return QuizEntity(
      quizId: model.quizId,
      materialId: model.materialId,
      format: switch (model.format) {
        QuizFormatType.multipleChoice => .multipleChoice,
        QuizFormatType.ox => .ox,
        QuizFormatType.$unknown => throw const FormatException(
          '지원하지 않는 문제 형식입니다.',
        ),
      },
      difficulty: switch (model.difficulty) {
        QuizDifficultyLevel.easy => .easy,
        QuizDifficultyLevel.normal => .normal,
        QuizDifficultyLevel.hard => .hard,
        QuizDifficultyLevel.$unknown => throw const FormatException(
          '지원하지 않는 난이도입니다.',
        ),
      },
      questions: List.unmodifiable(
        orderedQuestions.map(QuizQuestionEntity.fromModel),
      ),
    );
  }

  final int quizId;
  final int? materialId;
  final QuizFormat format;
  final QuizDifficulty difficulty;
  final List<QuizQuestionEntity> questions;
}
