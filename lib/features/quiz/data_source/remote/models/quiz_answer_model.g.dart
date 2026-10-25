// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_answer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizAnswerModel _$QuizAnswerModelFromJson(Map<String, dynamic> json) =>
    QuizAnswerModel(
      questionId: (json['questionId'] as num).toInt(),
      optionId: (json['optionId'] as num).toInt(),
    );

Map<String, dynamic> _$QuizAnswerModelToJson(QuizAnswerModel instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'optionId': instance.optionId,
    };
