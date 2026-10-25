import 'package:iquiz/features/quiz/repositories/enums/quiz_generation_status.enum.dart';

final class QuizGenerationJobEntity {
  const QuizGenerationJobEntity({
    required this.jobId,
    required this.status,
    this.quizId,
    this.error,
  });

  final int jobId;
  final QuizGenerationStatus status;
  final int? quizId;
  final Exception? error;
}
