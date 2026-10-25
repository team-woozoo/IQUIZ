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

  final int quizId;
  final int? materialId;
  final QuizFormat format;
  final QuizDifficulty difficulty;
  final List<QuizQuestionEntity> questions;
}
