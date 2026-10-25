// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_last_submission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizLastSubmissionModel _$QuizLastSubmissionModelFromJson(
  Map<String, dynamic> json,
) => QuizLastSubmissionModel(
  correctCount: (json['correctCount'] as num).toInt(),
  submittedAt: DateTime.parse(json['submittedAt'] as String),
);

Map<String, dynamic> _$QuizLastSubmissionModelToJson(
  QuizLastSubmissionModel instance,
) => <String, dynamic>{
  'correctCount': instance.correctCount,
  'submittedAt': instance.submittedAt.toIso8601String(),
};
