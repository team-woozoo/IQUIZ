final class QuizOptionEntity {
  const QuizOptionEntity({
    required this.optionId,
    required this.content,
    required this.isCorrect,
  });

  final int optionId;
  final String content;
  final bool isCorrect;
}
