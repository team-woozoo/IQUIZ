// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_generation_job_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizGenerationJobModel _$QuizGenerationJobModelFromJson(
  Map<String, dynamic> json,
) => QuizGenerationJobModel(
  jobId: (json['jobId'] as num).toInt(),
  status: QuizJobStatus.fromJson(json['status'] as String),
  quizId: (json['quizId'] as num?)?.toInt(),
  errorCode: json['errorCode'] as String?,
);

Map<String, dynamic> _$QuizGenerationJobModelToJson(
  QuizGenerationJobModel instance,
) => <String, dynamic>{
  'jobId': instance.jobId,
  'status': _$QuizJobStatusEnumMap[instance.status]!,
  'quizId': instance.quizId,
  'errorCode': instance.errorCode,
};

const _$QuizJobStatusEnumMap = {
  QuizJobStatus.pending: 'PENDING',
  QuizJobStatus.processing: 'PROCESSING',
  QuizJobStatus.done: 'DONE',
  QuizJobStatus.failed: 'FAILED',
  QuizJobStatus.$unknown: r'$unknown',
};
