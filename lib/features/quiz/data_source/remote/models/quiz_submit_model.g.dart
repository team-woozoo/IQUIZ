// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_submit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizSubmitModel _$QuizSubmitModelFromJson(Map<String, dynamic> json) =>
    QuizSubmitModel(
      answers: (json['answers'] as List<dynamic>)
          .map((e) => QuizAnswerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuizSubmitModelToJson(QuizSubmitModel instance) =>
    <String, dynamic>{'answers': instance.answers};
