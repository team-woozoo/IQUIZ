part of '../quiz_play_page.dart';

class _QuizQuestionHeader extends StatelessWidget with QuizPlayEvent {
  const _QuizQuestionHeader({required this.quiz, required this.session});
  final QuizEntity quiz;
  final QuizSessionState session;

  @override
  Widget build(BuildContext context) => QuizToolbar(
    current: session.index.value + 1,
    total: quiz.questions.length,
    onBack: () => onBackTapped(context),
  );
}
