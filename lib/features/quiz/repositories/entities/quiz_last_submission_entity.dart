final class QuizLastSubmissionEntity {
  const QuizLastSubmissionEntity({
    required this.correctCount,
    required this.submittedAt,
  });

  final int correctCount;
  final DateTime submittedAt;
}
