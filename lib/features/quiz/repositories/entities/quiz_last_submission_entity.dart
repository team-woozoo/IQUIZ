import 'package:iquiz/features/quiz/data_source/remote/models/quiz_last_submission_model.dart';

final class QuizLastSubmissionEntity {
  const QuizLastSubmissionEntity({
    required this.correctCount,
    required this.submittedAt,
  });

  factory QuizLastSubmissionEntity.fromModel(QuizLastSubmissionModel model) =>
      QuizLastSubmissionEntity(
        correctCount: model.correctCount,
        submittedAt: model.submittedAt,
      );

  final int correctCount;
  final DateTime submittedAt;
}
