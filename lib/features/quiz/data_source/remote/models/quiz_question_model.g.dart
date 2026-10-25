// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizQuestionModel _$QuizQuestionModelFromJson(Map<String, dynamic> json) =>
    QuizQuestionModel(
      questionId: (json['questionId'] as num).toInt(),
      orderNo: (json['orderNo'] as num).toInt(),
      content: json['content'] as String,
      cognitiveType: QuestionCognitiveType.fromJson(
        json['cognitiveType'] as String,
      ),
      conceptName: json['conceptName'] as String,
      explanation: json['explanation'] as String,
      sourceQuote: json['sourceQuote'] as String,
      sourcePageNo: (json['sourcePageNo'] as num?)?.toInt(),
      options: (json['options'] as List<dynamic>)
          .map((e) => QuizOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuizQuestionModelToJson(QuizQuestionModel instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'orderNo': instance.orderNo,
      'content': instance.content,
      'cognitiveType': _$QuestionCognitiveTypeEnumMap[instance.cognitiveType]!,
      'conceptName': instance.conceptName,
      'explanation': instance.explanation,
      'sourceQuote': instance.sourceQuote,
      'sourcePageNo': instance.sourcePageNo,
      'options': instance.options,
    };

const _$QuestionCognitiveTypeEnumMap = {
  QuestionCognitiveType.remember: 'REMEMBER',
  QuestionCognitiveType.understand: 'UNDERSTAND',
  QuestionCognitiveType.apply: 'APPLY',
  QuestionCognitiveType.analyze: 'ANALYZE',
  QuestionCognitiveType.evaluate: 'EVALUATE',
  QuestionCognitiveType.$unknown: r'$unknown',
};
