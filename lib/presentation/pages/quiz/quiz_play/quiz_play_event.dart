part of 'quiz_play_page.dart';

mixin class QuizPlayEvent {
  void onBackTapped(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      onUploadTapped(context);
    }
  }

  void onRetry(WidgetRef ref) => ref.invalidate(quizDetailProvider);

  void onOptionTapped(QuizSessionState session, int questionId, int optionId) {
    if (session.checked.value.contains(questionId)) return;
    session.answers.value = {...session.answers.value, questionId: optionId};
    session.checked.value = {...session.checked.value, questionId};
  }

  void onPreviousTapped(QuizSessionState session) {
    if (session.index.value > 0) session.index.value--;
  }

  Future<void> onNextTapped(
    WidgetRef ref,
    QuizEntity quiz,
    QuizSessionState session, {
    String? title,
  }) async {
    final questionId = quiz.questions[session.index.value].questionId;
    if (!session.checked.value.contains(questionId) ||
        session.openingResult.value) {
      return;
    }
    if (session.index.value == quiz.questions.length - 1) {
      await onSubmitTapped(ref, quiz, session, materialTitle: title);
    } else {
      session.index.value++;
    }
  }

  void onRestartTapped(WidgetRef ref, QuizSessionState session) {
    ref.read(quizSubmitProvider.notifier).reset();
    session.answers.value = {};
    session.checked.value = {};
    session.index.value = 0;
  }

  Future<void> onSubmitTapped(
    WidgetRef ref,
    QuizEntity quiz,
    QuizSessionState session, {
    String? materialTitle,
  }) async {
    if (session.openingResult.value || ref.read(quizSubmitProvider).isLoading) {
      return;
    }
    session.openingResult.value = true;
    final context = ref.context;
    final submittedAnswers = [
      for (final answer in session.answers.value.entries)
        QuizAnswerEntity(questionId: answer.key, optionId: answer.value),
    ];
    try {
      final result = await ref
          .read(quizSubmitProvider.notifier)
          .submit(quiz: quiz, answers: submittedAnswers);
      if (!context.mounted || result == null) return;
      final restart = await QuizResultRoute(
        quiz.quizId,
        $extra: QuizResultRouteArg(
          quiz: quiz,
          submission: result,
          answers: submittedAnswers,
          materialTitle: materialTitle,
        ),
      ).push<bool>(context);
      if (context.mounted && restart == true) onRestartTapped(ref, session);
    } finally {
      if (context.mounted) session.openingResult.value = false;
    }
  }

  void onUploadTapped(BuildContext context) => const UploadRoute().go(context);
}
