part of 'wrong_answers_page.dart';

mixin class WrongAnswersEvent {
  Future<void> onRefresh(WidgetRef ref) async {
    try {
      final load = ref.refresh(myWrongAnswersProvider.future);
      await load;
    } catch (_) {
      // 조회 오류와 재시도 버튼은 목록에서 표시
    }
  }

  Future<void> onQuestionTapped(
    WidgetRef ref,
    WrongAnswerEntity question,
    ValueNotifier<bool> opening,
  ) async {
    if (opening.value) return;
    opening.value = true;
    final context = ref.context;
    try {
      await WrongAnswerReviewRoute(
        question.questionId,
        $extra: question,
      ).push<void>(context);
    } finally {
      if (context.mounted) opening.value = false;
    }
  }
}
