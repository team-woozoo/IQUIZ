part of 'material_detail_page.dart';

mixin class MaterialDetailEvent {
  Future<void> onGenerateTapped(
    BuildContext context,
    StudyMaterialEntity material,
  ) => UploadRoute(
    materialId: material.materialId,
    materialTitle: material.title,
  ).push<void>(context);

  Future<void> onPlayTapped(
    WidgetRef ref,
    StudyMaterialEntity material,
    ValueNotifier<bool> opening,
  ) async {
    if (opening.value) return;
    opening.value = true;
    final context = ref.context;
    try {
      final quizId = await showModalBottomSheet<int>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        backgroundColor: AppColor.white,
        builder: (_) => _MaterialQuizSelectionSheet(material: material),
      );
      if (!context.mounted || quizId == null) return;
      await onQuizTapped(context, quizId, title: material.title);
    } finally {
      if (context.mounted) opening.value = false;
    }
  }

  void onBackTapped(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      goToHome(context);
    }
  }

  Future<void> onRefresh(WidgetRef ref, int materialId) async {
    final detail = ref.refresh(
      myMaterialProvider(materialId: materialId).future,
    );
    final concepts = ref.refresh(
      myMaterialConceptsProvider(materialId: materialId).future,
    );
    final quizzes = ref.refresh(
      materialQuizzesProvider(materialId: materialId).future,
    );
    ref.invalidate(myMaterialsProvider);
    try {
      await Future.wait<Object?>([detail, concepts, quizzes]);
    } catch (_) {
      // 각 영역의 오류 상태와 재시도 동작으로 안내
    }
  }

  Future<void> onQuizTapped(
    BuildContext context,
    int quizId, {
    String? title,
  }) => QuizRoute(quizId, title: title).push<void>(context);
}
