import 'package:iquiz/features/quiz/repositories/entities/quiz_last_submission_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_difficulty.enum.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_format.enum.dart';

final class QuizSummaryEntity {
  const QuizSummaryEntity({
    required this.quizId,
    this.materialId,
    required this.materialTitle,
    required this.format,
    required this.difficulty,
    required this.questionCount,
    required this.createdAt,
    required this.submissionCount,
    required this.lastSubmission,
  });

  final int quizId;
  final int? materialId;
  final String? materialTitle;
  final QuizFormat format;
  final QuizDifficulty difficulty;
  final int questionCount;
  final DateTime createdAt;
  final int submissionCount;
  final QuizLastSubmissionEntity? lastSubmission;
}
