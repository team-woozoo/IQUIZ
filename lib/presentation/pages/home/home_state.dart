part of 'home_page.dart';

mixin class HomeState {
  AsyncValue<List<StudyMaterialEntity>> materialsAsync(WidgetRef ref) =>
      ref.watch(myMaterialsProvider);

  AsyncValue<List<WeakConceptEntity>> weakConceptsAsync(WidgetRef ref) =>
      ref.watch(myWeakConceptsProvider);

  List<QuizGenerationActivityEntry> generatingMaterials(WidgetRef ref) =>
      ref.watch(quizGenerationActivityProvider);

  String generationLabel(QuizGenerationActivityEntry entry) =>
      entry.status == QuizGenerationStatus.uploading
      ? '자료 업로드 중...'
      : '문제 만드는 중...';

  /// 서버가 정답률 순으로 정렬한 첫 개념을 추천
  WeakConceptEntity? reviewConcept(List<WeakConceptEntity> concepts) =>
      concepts.isEmpty ? null : concepts.first;

  String reviewTitle(WeakConceptEntity concept) =>
      '${concept.conceptName} 개념이 약해요';

  ({TextEditingController controller, String query}) useSearchState() {
    final controller = useTextEditingController();
    final query = useValueListenable(controller).text.trim().toLowerCase();
    return (controller: controller, query: query);
  }

  List<StudyMaterialEntity> matchingMaterials(
    List<StudyMaterialEntity> items,
    String query,
  ) => items
      .where((material) => material.title.toLowerCase().contains(query))
      .toList();

  String createdDate(StudyMaterialEntity material) {
    final createdAt = material.createdAt.toLocal();
    final hour = createdAt.hour % 12;
    return '${DateFormat('M월 d일').format(createdAt)} '
        '${createdAt.hour < 12 ? '오전' : '오후'} '
        '${hour == 0 ? 12 : hour}:${DateFormat('mm').format(createdAt)}';
  }

  String quizListError(Object error) => switch (error) {
    CustomException(:final detail) => detail,
    FormatException(:final message) => message,
    _ => '네트워크 연결을 확인하고 다시 시도해 주세요.',
  };
}
