part of 'wrong_answers_page.dart';

mixin class WrongAnswersState {
  /// 미해결 오답 목록의 데이터·로딩·오류 상태를 구독
  AsyncValue<List<WrongAnswerEntity>> answersAsync(WidgetRef ref) =>
      ref.watch(myWrongAnswersProvider);

  /// 오답의 자료별 필터를 구성할 학습 자료 목록의 비동기 상태를 구독
  AsyncValue<List<StudyMaterialEntity>> materialsAsync(WidgetRef ref) =>
      ref.watch(myMaterialsProvider);

  /// [materials]와 [answers]를 합쳐 자료 ID별 제목을 구성
  /// 자료 목록에 없는 항목도 오답 정보로 보완하며 같은 ID는 오답의 제목을 사용
  Map<int, String> materialTitles(
    AsyncValue<List<StudyMaterialEntity>> materials,
    AsyncValue<List<WrongAnswerEntity>> answers,
  ) => {
    for (final material
        in materials.asData?.value ?? const <StudyMaterialEntity>[])
      material.materialId: material.title,
    for (final answer in answers.asData?.value ?? const <WrongAnswerEntity>[])
      answer.materialId: answer.materialTitle,
  };

  /// [items]에서 [query]와 선택한 [materialId]에 해당하는 오답만 반환
  /// 소문자로 정리한 검색어를 문제·개념·자료 제목에서 찾으며 자료 ID가 없으면 전체 자료를 검색
  List<WrongAnswerEntity> matchingAnswers(
    List<WrongAnswerEntity> items, {
    required String query,
    int? materialId,
  }) => items
      .where(
        (item) =>
            (materialId == null || item.materialId == materialId) &&
            (query.isEmpty ||
                '${item.content} ${item.conceptName} ${item.materialTitle}'
                    .toLowerCase()
                    .contains(query)),
      )
      .toList();
}
