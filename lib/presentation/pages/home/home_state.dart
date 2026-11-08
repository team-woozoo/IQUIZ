part of 'home_page.dart';

mixin class HomeState {
  /// 현재 선택된 홈 내비게이션 탭을 구독
  HomeNavigationTab currentNavigationTab(WidgetRef ref) =>
      ref.watch(homeBottomNavigationProvider);

  /// 내 학습 자료 목록의 데이터·로딩·오류 상태를 구독
  AsyncValue<List<StudyMaterialEntity>> materialsAsync(WidgetRef ref) =>
      ref.watch(myMaterialsProvider);

  /// 복습 추천에 사용할 약한 개념 목록의 비동기 상태를 구독
  AsyncValue<List<WeakConceptEntity>> weakConceptsAsync(WidgetRef ref) =>
      ref.watch(myWeakConceptsProvider);

  /// 현재 생성 중인 학습 자료의 작업 목록을 구독
  List<QuizGenerationActivityEntry> generatingMaterials(WidgetRef ref) =>
      ref.watch(quizGenerationActivityProvider);

  /// [entry]의 상태에 따라 업로드 또는 문제 생성 안내 문구를 반환
  String generationLabel(QuizGenerationActivityEntry entry) =>
      entry.status == QuizGenerationStatus.uploading
      ? '자료 업로드 중...'
      : '문제 만드는 중...';

  /// 서버가 정답률 순으로 정렬한 [concepts]의 첫 개념을 추천
  /// 추천할 개념이 없으면 null을 반환
  WeakConceptEntity? reviewConcept(List<WeakConceptEntity> concepts) =>
      concepts.isEmpty ? null : concepts.first;

  /// [concept]의 이름으로 약점 복습 카드의 제목을 생성
  String reviewTitle(WeakConceptEntity concept) =>
      '${concept.conceptName} 개념이 약해요';

  /// 검색용 컨트롤러와 공백·대소문자를 정리한 검색어를 생성
  /// build에서 항상 같은 순서로 호출하며 컨트롤러는 Hook 수명주기에 맞춰 정리
  ({TextEditingController controller, String query}) useSearchState() {
    final controller = useTextEditingController();
    final query = useValueListenable(controller).text.trim().toLowerCase();
    return (controller: controller, query: query);
  }

  /// [items]에서 소문자로 정리한 [query]를 제목에 포함하는 자료를 반환
  /// 검색어가 비어 있으면 전체 목록을 유지
  List<StudyMaterialEntity> matchingMaterials(
    List<StudyMaterialEntity> items,
    String query,
  ) => items
      .where((material) => material.title.toLowerCase().contains(query))
      .toList();

  /// [material]의 생성 시각을 기기 현지 시각으로 변환해 날짜·오전오후·시간을 표시
  String createdDate(StudyMaterialEntity material) {
    final createdAt = material.createdAt.toLocal();
    final hour = createdAt.hour % 12;
    return '${DateFormat('M월 d일').format(createdAt)} '
        '${createdAt.hour < 12 ? '오전' : '오후'} '
        '${hour == 0 ? 12 : hour}:${DateFormat('mm').format(createdAt)}';
  }

  /// [error]의 상세 메시지 또는 목록 조회 실패에 대한 기본 안내 문구를 반환
  String quizListError(Object error) => switch (error) {
    CustomException(:final detail) => detail,
    FormatException(:final message) => message,
    _ => '네트워크 연결을 확인하고 다시 시도해 주세요.',
  };
}
