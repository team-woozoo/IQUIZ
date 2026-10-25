// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weak_concept_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeakConceptModel _$WeakConceptModelFromJson(Map<String, dynamic> json) =>
    WeakConceptModel(
      conceptId: (json['conceptId'] as num).toInt(),
      conceptName: json['conceptName'] as String,
      materialId: (json['materialId'] as num).toInt(),
      materialTitle: json['materialTitle'] as String,
      answeredCount: (json['answeredCount'] as num).toInt(),
      correctAnswerCount: (json['correctAnswerCount'] as num).toInt(),
      accuracy: (json['accuracy'] as num).toDouble(),
    );

Map<String, dynamic> _$WeakConceptModelToJson(WeakConceptModel instance) =>
    <String, dynamic>{
      'conceptId': instance.conceptId,
      'conceptName': instance.conceptName,
      'materialId': instance.materialId,
      'materialTitle': instance.materialTitle,
      'answeredCount': instance.answeredCount,
      'correctAnswerCount': instance.correctAnswerCount,
      'accuracy': instance.accuracy,
    };
