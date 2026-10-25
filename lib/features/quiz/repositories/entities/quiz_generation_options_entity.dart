import 'package:iquiz/features/quiz/repositories/enums/quiz_difficulty.enum.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_format.enum.dart';

final class QuizGenerationOptionsEntity {
  const QuizGenerationOptionsEntity({
    required this.format,
    required this.difficulty,
  });

  final QuizFormat format;
  final QuizDifficulty difficulty;
}
