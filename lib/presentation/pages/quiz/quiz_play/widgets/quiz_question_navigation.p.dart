part of '../quiz_play_page.dart';

class _QuizQuestionNavigation extends ConsumerWidget
    with QuizPlayState, QuizPlayEvent {
  const _QuizQuestionNavigation({
    required this.quiz,
    required this.session,
    required this.submitting,
    this.title,
  });
  final QuizEntity quiz;
  final QuizSessionState session;
  final bool submitting;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) => QuizActionButton(
    label: submitting
        ? '결과 저장 중...'
        : isLast(quiz, session)
        ? '결과 보기'
        : '다음 문제',
    onPressed: submitting
        ? null
        : () => onNextTapped(ref, quiz, session, title: title),
  );
}
