// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_option_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizOptionModel _$QuizOptionModelFromJson(Map<String, dynamic> json) =>
    QuizOptionModel(
      optionId: (json['optionId'] as num).toInt(),
      orderNo: (json['orderNo'] as num).toInt(),
      content: json['content'] as String,
      isCorrect: json['isCorrect'] as bool,
    );

Map<String, dynamic> _$QuizOptionModelToJson(QuizOptionModel instance) =>
    <String, dynamic>{
      'optionId': instance.optionId,
      'orderNo': instance.orderNo,
      'content': instance.content,
      'isCorrect': instance.isCorrect,
    };
