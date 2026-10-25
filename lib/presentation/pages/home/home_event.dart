part of 'home_page.dart';

mixin class HomeEvent {
  Future<void> onRefresh(WidgetRef ref) async {
    try {
      final materials = ref.refresh(myMaterialsProvider.future);
      final concepts = ref.refresh(myWeakConceptsProvider.future);
      await Future.wait<Object?>([materials, concepts]);
    } catch (_) {
      // 목록의 오류 상태와 재시도 버튼에서 실패를 안내
    }
  }

  void onRetry(WidgetRef ref) => ref.invalidate(myMaterialsProvider);

  void onReviewRecommendationTapped(WidgetRef ref, WeakConceptEntity concept) {}

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

  Future<void> onUploadTapped(BuildContext context) =>
      const UploadRoute().push<void>(context);

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

  /// push의 반환값은 뒤로가기까지 기다리므로 이동한 첫 프레임에 잠금을 해제
  /// go로 홈에 복귀해도 미완료된 push가 홈의 클릭을 계속 막지 않게 처리
  Future<void> _waitForNavigationFrame(Future<void> navigation) =>
      Future.any<void>([navigation, WidgetsBinding.instance.endOfFrame]);

  void onSearchResultTapped(
    BuildContext context,
    StudyMaterialEntity material,
  ) => Navigator.of(context).pop(material);

  void onSearchCleared(TextEditingController controller) => controller.clear();
}
