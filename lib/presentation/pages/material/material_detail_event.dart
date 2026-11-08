part of 'material_detail_page.dart';

mixin class MaterialDetailEvent {
  /// [materialId]의 자료 상세 상태를 무효화해 다시 조회
  void onRetryMaterial(WidgetRef ref, int materialId) =>
      ref.invalidate(myMaterialProvider(materialId: materialId));

  /// [materialId]의 개념 목록 상태를 무효화해 다시 조회
  void onRetryConcepts(WidgetRef ref, int materialId) =>
      ref.invalidate(myMaterialConceptsProvider(materialId: materialId));

  /// [materialId]의 퀴즈 목록과 풀이 기록을 무효화해 다시 조회
  void onRetryQuizzes(WidgetRef ref, int materialId) =>
      ref.invalidate(materialQuizzesProvider(materialId: materialId));

  /// 앱이 다시 활성화되면 자료 목록과 [materialId]의 상세·개념·퀴즈 상태를 무효화
  /// 각 상태는 구독 또는 다음 조회 시 갱신
  void onResumeRefresh(WidgetRef ref, int materialId) {
    ref.invalidate(myMaterialsProvider);
    onRetryMaterial(ref, materialId);
    onRetryConcepts(ref, materialId);
    onRetryQuizzes(ref, materialId);
  }

  /// [material]의 ID와 제목을 전달해 PDF 재업로드 없이 퀴즈를 생성하는 화면을 표시
  Future<void> onGenerateTapped(
    BuildContext context,
    StudyMaterialEntity material,
  ) => UploadRoute(
    materialId: material.materialId,
    materialTitle: material.title,
  ).push<void>(context);

  /// [material]의 퀴즈 선택 시트를 열고 선택한 퀴즈의 풀이 화면으로 이동
  /// 선택 시트와 풀이 화면을 연 동안 중복 이동을 차단
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

  /// 이전 화면으로 돌아가며 돌아갈 화면이 없으면 홈으로 이동
  void onBackTapped(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      goToHome(context);
    }
  }

  /// [materialId]의 상세·개념·퀴즈를 함께 다시 조회하고 자료 목록도 갱신
  /// 조회 실패는 각 영역의 오류 상태와 재시도 동작으로 안내
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

  /// [quizId]의 풀이 화면을 열고 선택적으로 자료 [title]을 전달
  Future<void> onQuizTapped(
    BuildContext context,
    int quizId, {
    String? title,
  }) => QuizRoute(quizId, title: title).push<void>(context);
}
