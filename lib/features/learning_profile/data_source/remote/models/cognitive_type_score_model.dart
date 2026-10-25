import 'package:json_annotation/json_annotation.dart';

import 'package:iquiz/features/learning_profile/data_source/remote/enums/cognitive_type_score_type.enum.dart';

part 'cognitive_type_score_model.g.dart';

///
/// 인지 유형별 정답률과 데이터 충분성
///
@JsonSerializable()
class CognitiveTypeScoreModel {
  const CognitiveTypeScoreModel({
    required this.cognitiveType,
    required this.answeredCount,
    required this.correctAnswerCount,
    required this.accuracy,
    required this.isEnoughData,
  });

  factory CognitiveTypeScoreModel.fromJson(Map<String, Object?> json) =>
      _$CognitiveTypeScoreModelFromJson(json);

  final CognitiveTypeScoreType cognitiveType;

  final int answeredCount;

  final int correctAnswerCount;

  final double? accuracy;

  final bool isEnoughData;

  Map<String, Object?> toJson() => _$CognitiveTypeScoreModelToJson(this);
}
