import 'package:json_annotation/json_annotation.dart';

part 'study_material_model.g.dart';

///
/// 업로드한 학습 자료 정보
///
@JsonSerializable()
class StudyMaterialModel {
  const StudyMaterialModel({
    required this.materialId,
    required this.title,
    required this.originalFilename,
    required this.pageCount,
    required this.createdAt,
    required this.questionCount,
    required this.answeredCount,
    required this.correctCount,
    required this.wrongCount,
    required this.accuracy,
    required this.generating,
  });

  factory StudyMaterialModel.fromJson(Map<String, Object?> json) =>
      _$StudyMaterialModelFromJson(json);

  final int materialId;
  final String title;
  final String originalFilename;

  final int pageCount;

  final DateTime createdAt;

  final int questionCount;

  final int answeredCount;

  final int correctCount;

  final int wrongCount;

  final double? accuracy;

  final bool generating;

  Map<String, Object?> toJson() => _$StudyMaterialModelToJson(this);
}
