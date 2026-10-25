import 'package:iquiz/features/quiz/repositories/enums/material_concept_state.enum.dart';

final class MaterialConceptEntity {
  const MaterialConceptEntity({
    required this.conceptId,
    required this.conceptName,
    required this.pageNos,
    required this.questionCount,
    required this.answeredCount,
    required this.correctCount,
    required this.accuracy,
    required this.status,
  });

  final int conceptId;
  final String conceptName;

  /// PDF 실제 페이지 번호의 목록. 연속된 범위라고 가정하지 않음
  final List<int> pageNos;
  final int questionCount;
  final int answeredCount;
  final int correctCount;

  /// 전체 문제 수를 분모로 사용. 문제가 없을 때만 null
  final double? accuracy;

  /// 정답률로 재계산하지 않고 서버의 상태를 유지
  final MaterialConceptState status;
}
