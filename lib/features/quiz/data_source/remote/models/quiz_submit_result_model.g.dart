// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_submit_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizSubmitResultModel _$QuizSubmitResultModelFromJson(
  Map<String, dynamic> json,
) => QuizSubmitResultModel(
  submissionId: (json['submissionId'] as num).toInt(),
  correctCount: (json['correctCount'] as num).toInt(),
  totalCount: (json['totalCount'] as num).toInt(),
  results: (json['results'] as List<dynamic>)
      .map((e) => QuizQuestionResultModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$QuizSubmitResultModelToJson(
  QuizSubmitResultModel instance,
) => <String, dynamic>{
  'submissionId': instance.submissionId,
  'correctCount': instance.correctCount,
  'totalCount': instance.totalCount,
  'results': instance.results,
};
