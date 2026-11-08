import 'package:iquiz/features/quiz/data_source/remote/enums/material_concept_status.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/material_concept_model.dart';
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

  factory MaterialConceptEntity.fromModel(MaterialConceptModel model) {
    _validateStatistics(
      model.questionCount,
      model.answeredCount,
      model.correctCount,
      model.accuracy,
    );
    if (model.conceptId <= 0 || model.pageNos.any((page) => page <= 0)) {
      throw const FormatException('개념 정보 또는 PDF 페이지 번호가 올바르지 않습니다.');
    }
    return MaterialConceptEntity(
      conceptId: model.conceptId,
      conceptName: model.conceptName,
      pageNos: List.unmodifiable(model.pageNos),
      questionCount: model.questionCount,
      answeredCount: model.answeredCount,
      correctCount: model.correctCount,
      accuracy: model.accuracy,
      status: switch (model.status) {
        MaterialConceptStatus.weak => .weak,
        MaterialConceptStatus.good => .good,
        MaterialConceptStatus.perfect => .perfect,
        MaterialConceptStatus.unchecked => .unchecked,
        MaterialConceptStatus.$unknown => throw const FormatException(
          '지원하지 않는 개념 상태입니다.',
        ),
      },
    );
  }

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

void _validateStatistics(
  int questionCount,
  int answeredCount,
  int correctCount,
  double? accuracy,
) {
  if (questionCount < 0 ||
      answeredCount < 0 ||
      answeredCount > questionCount ||
      correctCount < 0 ||
      correctCount > answeredCount ||
      (questionCount == 0) != (accuracy == null) ||
      (accuracy != null &&
          (!accuracy.isFinite || accuracy < 0 || accuracy > 1))) {
    throw const FormatException('자료 학습 집계가 올바르지 않습니다.');
  }
}
