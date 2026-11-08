part of 'quiz_play_page.dart';

mixin class QuizPlayEvent {
  /// 이전 화면으로 돌아가며 돌아갈 화면이 없으면 업로드 화면으로 이동
  void onBackTapped(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      onUploadTapped(context);
    }
  }

  /// 현재 퀴즈의 상세 상태를 무효화해 조회를 다시 시도
  void onRetry(WidgetRef ref) => ref.invalidate(quizDetailProvider);

  /// [questionId]의 선택 답안을 [optionId]로 기록하고 정답 확인 상태로 변경
  /// 이미 확인한 문제의 답안은 변경하지 않음
  void onOptionTapped(QuizSessionState session, int questionId, int optionId) {
    if (session.checked.value.contains(questionId)) return;
    session.answers.value = {...session.answers.value, questionId: optionId};
    session.checked.value = {...session.checked.value, questionId};
  }

  /// 첫 문제가 아닌 경우 [session]의 현재 위치를 이전 문제로 변경
  void onPreviousTapped(QuizSessionState session) {
    if (session.index.value > 0) session.index.value--;
  }

  /// 현재 문제의 답안을 확인했다면 다음 문제로 이동
  /// 마지막 문제이면 답안을 제출하며 결과 화면으로 이동 중에는 중복 처리를 차단
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

  /// 서버 제출 결과와 [session]의 답안·확인 상태를 초기화하고 첫 문제로 이동
  void onRestartTapped(WidgetRef ref, QuizSessionState session) {
    ref.read(quizSubmitProvider.notifier).reset();
    session.answers.value = {};
    session.checked.value = {};
    session.index.value = 0;
  }

  /// [session]의 선택 답안을 제출하고 채점 결과와 함께 결과 화면으로 이동
  /// 중복 제출·이동을 차단하며 결과 화면에서 다시 풀기를 선택하면 풀이 상태를 초기화
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

  /// 학습 자료 업로드 화면으로 이동
  void onUploadTapped(BuildContext context) => const UploadRoute().go(context);
}
