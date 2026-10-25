final class QuizQuestionResultEntity {
  const QuizQuestionResultEntity({
    required this.questionId,
    required this.correct,
  });

  final int questionId;
  final bool correct;
}
