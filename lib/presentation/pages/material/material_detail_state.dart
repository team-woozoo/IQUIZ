part of 'material_detail_page.dart';

mixin class MaterialDetailState {
  /// [materialId]에 해당하는 자료 상세의 데이터·로딩·오류 상태를 구독
  AsyncValue<StudyMaterialEntity?> materialAsync(
    WidgetRef ref,
    int materialId,
  ) => ref.watch(myMaterialProvider(materialId: materialId));

  /// [materialId]에 해당하는 자료의 개념별 학습 집계와 상태를 구독
  AsyncValue<List<MaterialConceptEntity>> conceptsAsync(
    WidgetRef ref,
    int materialId,
  ) => ref.watch(myMaterialConceptsProvider(materialId: materialId));

  /// [materialId]에 해당하는 퀴즈 목록과 풀이 기록의 비동기 상태를 구독
  AsyncValue<List<QuizSummaryEntity>> quizzesAsync(
    WidgetRef ref,
    int materialId,
  ) => ref.watch(materialQuizzesProvider(materialId: materialId));

  /// [error]의 종류에 따라 자료 없음·서버 상세 오류·기본 조회 실패 문구를 반환
  String materialError(Object error) => switch (error) {
    MaterialNotFoundException() => '자료를 찾을 수 없어요.',
    CustomException(:final detail) => detail,
    FormatException(:final message) => message,
    _ => '자료를 불러오지 못했어요. 네트워크 연결을 확인해 주세요.',
  };

  /// [date]를 기기 현지 날짜로 변환해 월·일·요일 형식으로 표시
  String historyDate(DateTime date) {
    final local = date.toLocal();
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${DateFormat('M월 d일').format(local)} (${weekdays[local.weekday - 1]})';
  }
}
