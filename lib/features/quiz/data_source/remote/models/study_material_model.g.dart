// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_material_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyMaterialModel _$StudyMaterialModelFromJson(Map<String, dynamic> json) =>
    StudyMaterialModel(
      materialId: (json['materialId'] as num).toInt(),
      title: json['title'] as String,
      originalFilename: json['originalFilename'] as String,
      pageCount: (json['pageCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      questionCount: (json['questionCount'] as num).toInt(),
      answeredCount: (json['answeredCount'] as num).toInt(),
      correctCount: (json['correctCount'] as num).toInt(),
      wrongCount: (json['wrongCount'] as num).toInt(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      generating: json['generating'] as bool,
    );

Map<String, dynamic> _$StudyMaterialModelToJson(StudyMaterialModel instance) =>
    <String, dynamic>{
      'materialId': instance.materialId,
      'title': instance.title,
      'originalFilename': instance.originalFilename,
      'pageCount': instance.pageCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'questionCount': instance.questionCount,
      'answeredCount': instance.answeredCount,
      'correctCount': instance.correctCount,
      'wrongCount': instance.wrongCount,
      'accuracy': instance.accuracy,
      'generating': instance.generating,
    };
