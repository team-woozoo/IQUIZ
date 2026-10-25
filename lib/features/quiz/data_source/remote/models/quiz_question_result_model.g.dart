// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_question_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizQuestionResultModel _$QuizQuestionResultModelFromJson(
  Map<String, dynamic> json,
) => QuizQuestionResultModel(
  questionId: (json['questionId'] as num).toInt(),
  correct: json['correct'] as bool,
);

Map<String, dynamic> _$QuizQuestionResultModelToJson(
  QuizQuestionResultModel instance,
) => <String, dynamic>{
  'questionId': instance.questionId,
  'correct': instance.correct,
};
