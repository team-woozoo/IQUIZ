part of 'profile_page.dart';

mixin class ProfileEvent {
  /// 중복 요청을 막으며 로그아웃하고 인증 정보 삭제 실패 시 안내 메시지를 표시
  /// 화면이 유지되는 동안 [signingOut]으로 버튼의 진행 상태를 관리
  Future<void> onSignOutTapped(
    WidgetRef ref,
    ValueNotifier<bool> signingOut,
  ) async {
    if (signingOut.value) return;
    signingOut.value = true;
    final context = ref.context;
    try {
      final result = await ref.read(userAuthProvider.notifier).signOut();
      if (!context.mounted) return;
      result.fold(
        onSuccess: (_) {},
        onFailure: (_) => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증 정보 삭제에 실패했습니다. 다시 시도해 주세요.')),
        ),
      );
    } finally {
      if (context.mounted) signingOut.value = false;
    }
  }

  /// 인지 유형별 학습 분석과 약한 개념 목록을 함께 다시 조회
  /// 조회 실패는 각 영역의 오류 상태와 재시도 버튼으로 안내
  Future<void> onRefresh(WidgetRef ref) async {
    try {
      await Future.wait<Object?>([
        ref.refresh(myCognitiveTypeScoresProvider.future),
        ref.refresh(myWeakConceptsProvider.future),
      ]);
    } catch (_) {
      // 각 영역에서 오류와 재시도 버튼을 표시
    }
  }

  /// 인지 유형별 학습 분석 상태를 무효화해 조회를 다시 시도
  void onRetryScores(WidgetRef ref) =>
      ref.invalidate(myCognitiveTypeScoresProvider);

  /// 약한 개념 목록을 무효화해 조회를 다시 시도
  void onRetryWeakConcepts(WidgetRef ref) =>
      ref.invalidate(myWeakConceptsProvider);

  /// 맞춤 퀴즈를 만들 약한 개념을 선택하는 하단 시트를 표시
  Future<void> onWeakConceptsTapped(BuildContext context) =>
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        useSafeArea: true,
        isScrollControlled: true,
        backgroundColor: AppColor.white,
        builder: (_) => const _ProfileWeakConceptsSheet(),
      );

  /// 약한 개념 선택 시트를 닫고 [concept]의 ID와 이름으로 맞춤 퀴즈 생성 화면을 표시
  void onWeakConceptTapped(BuildContext context, WeakConceptEntity concept) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    unawaited(
      router.push<void>(
        UploadRoute(
          conceptId: concept.conceptId,
          conceptName: concept.conceptName,
        ).location,
      ),
    );
  }
}
