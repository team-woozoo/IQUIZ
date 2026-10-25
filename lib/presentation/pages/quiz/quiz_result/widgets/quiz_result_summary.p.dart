part of '../quiz_result_page.dart';

class _QuizResultSummary extends StatelessWidget {
  const _QuizResultSummary({required this.data});
  final QuizResultRouteArg data;

  @override
  Widget build(BuildContext context) {
    final total = data.quiz.questions.length;
    final answered = data.answers
        .map((answer) => answer.questionId)
        .toSet()
        .length;
    return QuizScoreSummary(
      total: total,
      correct: data.submission.correctCount,
      wrong: answered - data.submission.correctCount,
      unanswered: total - answered,
      countKeyPrefix: 'quiz_result_count',
    );
  }
}
