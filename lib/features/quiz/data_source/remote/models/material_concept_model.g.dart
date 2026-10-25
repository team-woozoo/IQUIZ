// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_concept_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaterialConceptModel _$MaterialConceptModelFromJson(
  Map<String, dynamic> json,
) => MaterialConceptModel(
  conceptId: (json['conceptId'] as num).toInt(),
  conceptName: json['conceptName'] as String,
  pageNos: (json['pageNos'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  questionCount: (json['questionCount'] as num).toInt(),
  answeredCount: (json['answeredCount'] as num).toInt(),
  correctCount: (json['correctCount'] as num).toInt(),
  accuracy: (json['accuracy'] as num?)?.toDouble(),
  status: MaterialConceptStatus.fromJson(json['status'] as String),
);

Map<String, dynamic> _$MaterialConceptModelToJson(
  MaterialConceptModel instance,
) => <String, dynamic>{
  'conceptId': instance.conceptId,
  'conceptName': instance.conceptName,
  'pageNos': instance.pageNos,
  'questionCount': instance.questionCount,
  'answeredCount': instance.answeredCount,
  'correctCount': instance.correctCount,
  'accuracy': instance.accuracy,
  'status': _$MaterialConceptStatusEnumMap[instance.status]!,
};

const _$MaterialConceptStatusEnumMap = {
  MaterialConceptStatus.weak: 'WEAK',
  MaterialConceptStatus.good: 'GOOD',
  MaterialConceptStatus.perfect: 'PERFECT',
  MaterialConceptStatus.unchecked: 'UNCHECKED',
  MaterialConceptStatus.$unknown: r'$unknown',
};
