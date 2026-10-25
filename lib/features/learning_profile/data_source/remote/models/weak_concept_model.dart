import 'package:json_annotation/json_annotation.dart';

part 'weak_concept_model.g.dart';

///
/// 자료별 취약 개념과 최근 답안 기준 정답률
///
@JsonSerializable()
class WeakConceptModel {
  const WeakConceptModel({
    required this.conceptId,
    required this.conceptName,
    required this.materialId,
    required this.materialTitle,
    required this.answeredCount,
    required this.correctAnswerCount,
    required this.accuracy,
  });

  factory WeakConceptModel.fromJson(Map<String, Object?> json) =>
      _$WeakConceptModelFromJson(json);

  final int conceptId;
  final String conceptName;

  final int materialId;
  final String materialTitle;

  final int answeredCount;

  final int correctAnswerCount;

  final double accuracy;

  Map<String, Object?> toJson() => _$WeakConceptModelToJson(this);
}
