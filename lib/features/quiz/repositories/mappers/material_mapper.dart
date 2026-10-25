import 'package:iquiz/features/quiz/data_source/remote/enums/material_concept_status.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/material_concept_model.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/study_material_model.dart';
import 'package:iquiz/features/quiz/repositories/entities/material_concept_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/study_material_entity.dart';

extension StudyMaterialMapper on StudyMaterialModel {
  StudyMaterialEntity toEntity() {
    _validateStatistics(questionCount, answeredCount, correctCount, accuracy);
    if (materialId <= 0 ||
        pageCount < 0 ||
        wrongCount != questionCount - correctCount) {
      throw const FormatException('자료 정보 또는 오답 집계가 올바르지 않습니다.');
    }
    return StudyMaterialEntity(
      materialId: materialId,
      title: title,
      originalFilename: originalFilename,
      pageCount: pageCount,
      createdAt: createdAt,
      questionCount: questionCount,
      answeredCount: answeredCount,
      correctCount: correctCount,
      wrongCount: wrongCount,
      accuracy: accuracy,
      generating: generating,
    );
  }
}

extension MaterialConceptMapper on MaterialConceptModel {
  MaterialConceptEntity toEntity() {
    _validateStatistics(questionCount, answeredCount, correctCount, accuracy);
    if (conceptId <= 0 || pageNos.any((page) => page <= 0)) {
      throw const FormatException('개념 정보 또는 PDF 페이지 번호가 올바르지 않습니다.');
    }
    return MaterialConceptEntity(
      conceptId: conceptId,
      conceptName: conceptName,
      pageNos: List.unmodifiable(pageNos),
      questionCount: questionCount,
      answeredCount: answeredCount,
      correctCount: correctCount,
      accuracy: accuracy,
      status: switch (status) {
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
