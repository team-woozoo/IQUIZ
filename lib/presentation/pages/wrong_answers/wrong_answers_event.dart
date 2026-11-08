part of 'wrong_answers_page.dart';

mixin class WrongAnswersEvent {
  /// 미해결 오답 목록을 무효화해 조회를 다시 시도
  void onRetry(WidgetRef ref) => ref.invalidate(myWrongAnswersProvider);

  /// 검색창의 표시 상태를 전환하고 닫을 때 [search]의 검색어를 초기화
  void onSearchToggled(
    ValueNotifier<bool> searchOpen,
    TextEditingController search,
  ) {
    searchOpen.value = !searchOpen.value;
    if (!searchOpen.value) search.clear();
  }

  /// 오답노트에서 학습 자료 업로드 화면으로 이동
  Future<void> onUploadTapped(BuildContext context) =>
      const UploadRoute().push<void>(context);

  /// 미해결 오답 목록을 다시 조회하고 완료될 때까지 대기
  /// 조회 실패는 목록의 오류 상태와 재시도 버튼으로 안내
  Future<void> onRefresh(WidgetRef ref) async {
    try {
      final load = ref.refresh(myWrongAnswersProvider.future);
      await load;
    } catch (_) {
      // 조회 오류와 재시도 버튼은 목록에서 표시
    }
  }

  /// [question]을 전달해 오답 복습 화면을 표시
  /// 화면을 열어 둔 동안 [opening]으로 중복 이동을 차단
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
