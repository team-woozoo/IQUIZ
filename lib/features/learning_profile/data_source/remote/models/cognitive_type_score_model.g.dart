// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cognitive_type_score_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CognitiveTypeScoreModel _$CognitiveTypeScoreModelFromJson(
  Map<String, dynamic> json,
) => CognitiveTypeScoreModel(
  cognitiveType: CognitiveTypeScoreType.fromJson(
    json['cognitiveType'] as String,
  ),
  answeredCount: (json['answeredCount'] as num).toInt(),
  correctAnswerCount: (json['correctAnswerCount'] as num).toInt(),
  accuracy: (json['accuracy'] as num?)?.toDouble(),
  isEnoughData: json['isEnoughData'] as bool,
);

Map<String, dynamic> _$CognitiveTypeScoreModelToJson(
  CognitiveTypeScoreModel instance,
) => <String, dynamic>{
  'cognitiveType': _$CognitiveTypeScoreTypeEnumMap[instance.cognitiveType]!,
  'answeredCount': instance.answeredCount,
  'correctAnswerCount': instance.correctAnswerCount,
  'accuracy': instance.accuracy,
  'isEnoughData': instance.isEnoughData,
};

const _$CognitiveTypeScoreTypeEnumMap = {
  CognitiveTypeScoreType.remember: 'REMEMBER',
  CognitiveTypeScoreType.understand: 'UNDERSTAND',
  CognitiveTypeScoreType.apply: 'APPLY',
  CognitiveTypeScoreType.analyze: 'ANALYZE',
  CognitiveTypeScoreType.evaluate: 'EVALUATE',
  CognitiveTypeScoreType.$unknown: r'$unknown',
};
