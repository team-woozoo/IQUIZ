import 'package:json_annotation/json_annotation.dart';

import 'package:iquiz/features/quiz/data_source/remote/enums/material_concept_status.enum.dart';

part 'material_concept_model.g.dart';

///
/// 자료의 개념별 학습 상태
///
@JsonSerializable()
class MaterialConceptModel {
  const MaterialConceptModel({
    required this.conceptId,
    required this.conceptName,
    required this.pageNos,
    required this.questionCount,
    required this.answeredCount,
    required this.correctCount,
    required this.accuracy,
    required this.status,
  });

  factory MaterialConceptModel.fromJson(Map<String, Object?> json) =>
      _$MaterialConceptModelFromJson(json);

  final int conceptId;
  final String conceptName;

  final List<int> pageNos;

  final int questionCount;

  final int answeredCount;

  final int correctCount;

  final double? accuracy;

  final MaterialConceptStatus status;

  Map<String, Object?> toJson() => _$MaterialConceptModelToJson(this);
}
