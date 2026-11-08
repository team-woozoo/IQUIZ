part of 'home_page.dart';

mixin class HomeEvent {
  /// 홈 내비게이션의 선택 상태를 [tab]으로 변경
  void onNavigationTabSelected(WidgetRef ref, HomeNavigationTab tab) =>
      ref.read(homeBottomNavigationProvider.notifier).changeTab(tab);

  /// 학습 자료와 약한 개념 목록을 함께 다시 조회하고 완료될 때까지 대기
  /// 조회 실패는 각 목록의 오류 상태와 재시도 버튼으로 안내
  Future<void> onRefresh(WidgetRef ref) async {
    try {
      final materials = ref.refresh(myMaterialsProvider.future);
      final concepts = ref.refresh(myWeakConceptsProvider.future);
      await Future.wait<Object?>([materials, concepts]);
    } catch (_) {
      // 목록의 오류 상태와 재시도 버튼에서 실패를 안내
    }
  }

  /// 학습 자료 목록을 무효화해 조회를 다시 시도
  void onRetry(WidgetRef ref) => ref.invalidate(myMaterialsProvider);

  /// 약점 개념 추천 카드의 탭 이벤트 진입점
  /// 현재 [concept]에 대한 추가 동작은 구현하지 않음
  void onReviewRecommendationTapped(WidgetRef ref, WeakConceptEntity concept) {}

  /// 자료 검색 시트를 열고 선택한 자료를 [onMaterialTapped]로 전달
  /// 자료 화면 이동 중이거나 검색을 취소한 경우 추가 이동을 하지 않음
  Future<void> onSearchTapped(
    WidgetRef ref,
    ValueNotifier<bool> opening,
  ) async {
    if (opening.value) return;
    final context = ref.context;
    final material = await showModalBottomSheet<StudyMaterialEntity>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColor.white,
      builder: (_) => const _HomeSearchSheet(),
    );
    if (!context.mounted || material == null) return;
    await onMaterialTapped(ref, material, opening);
  }

  /// 학습 자료 업로드 화면을 열고 해당 화면이 닫힐 때까지 대기
  Future<void> onUploadTapped(BuildContext context) =>
      const UploadRoute().push<void>(context);

  /// [material]에 풀이 기록이 있으면 자료 상세를, 없으면 가장 최근 생성된 유효한 퀴즈를 표시
  /// 중복 이동을 막고 퀴즈가 없거나 조회가 실패하면 안내 메시지를 표시
  Future<void> onMaterialTapped(
    WidgetRef ref,
    StudyMaterialEntity material,
    ValueNotifier<bool> opening,
  ) async {
    if (opening.value) return;
    opening.value = true;
    final context = ref.context;
    try {
      if (material.answeredCount > 0) {
        await _waitForNavigationFrame(
          MaterialDetailRoute(material.materialId).push<void>(context),
        );
        return;
      }

      final quizzes = await ref.read(
        materialQuizzesProvider(materialId: material.materialId).future,
      );
      if (!context.mounted) return;
      // 서버의 목록 순서에 의존하지 않고 가장 최근 생성된 문제를 열기
      final playable =
          quizzes
              .where(
                (quiz) =>
                    quiz.materialId == material.materialId &&
                    quiz.questionCount > 0,
              )
              .toList()
            ..sort((a, b) {
              final dateOrder = b.createdAt.compareTo(a.createdAt);
              return dateOrder != 0 ? dateOrder : b.quizId.compareTo(a.quizId);
            });
      if (playable.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              material.generating
                  ? '문제를 만들고 있어요. 잠시 후 다시 눌러 주세요.'
                  : '아직 생성된 문제가 없어요.',
            ),
          ),
        );
        return;
      }
      await _waitForNavigationFrame(
        QuizRoute(
          playable.first.quizId,
          title: material.title,
        ).push<void>(context),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('문제를 불러오지 못했어요. 다시 눌러 주세요.')),
      );
    } finally {
      if (context.mounted) opening.value = false;
    }
  }

  /// [navigation]의 종료 또는 화면 이동 후 첫 프레임까지 대기
  /// push가 뒤로가기까지 완료되지 않아도 홈의 이동 잠금을 해제할 수 있도록 처리
  Future<void> _waitForNavigationFrame(Future<void> navigation) =>
      Future.any<void>([navigation, WidgetsBinding.instance.endOfFrame]);

  /// 검색 시트를 닫으며 선택한 [material]을 호출한 화면에 반환
  void onSearchResultTapped(
    BuildContext context,
    StudyMaterialEntity material,
  ) => Navigator.of(context).pop(material);

  /// [controller]의 검색어를 지워 전체 자료 목록을 다시 표시
  void onSearchCleared(TextEditingController controller) => controller.clear();
}
