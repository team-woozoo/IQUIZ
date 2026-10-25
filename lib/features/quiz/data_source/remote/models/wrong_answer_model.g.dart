// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wrong_answer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WrongAnswerModel _$WrongAnswerModelFromJson(Map<String, dynamic> json) =>
    WrongAnswerModel(
      questionId: (json['questionId'] as num).toInt(),
      quizId: (json['quizId'] as num).toInt(),
      format: WrongAnswerFormat.fromJson(json['format'] as String),
      content: json['content'] as String,
      cognitiveType: WrongAnswerCognitiveType.fromJson(
        json['cognitiveType'] as String,
      ),
      conceptName: json['conceptName'] as String,
      materialId: (json['materialId'] as num).toInt(),
      materialTitle: json['materialTitle'] as String,
      explanation: json['explanation'] as String,
      sourceQuote: json['sourceQuote'] as String,
      sourcePageNo: (json['sourcePageNo'] as num?)?.toInt(),
      options: (json['options'] as List<dynamic>)
          .map((e) => QuizOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      wrongCount: (json['wrongCount'] as num).toInt(),
      lastWrongAt: DateTime.parse(json['lastWrongAt'] as String),
    );

Map<String, dynamic> _$WrongAnswerModelToJson(
  WrongAnswerModel instance,
) => <String, dynamic>{
  'questionId': instance.questionId,
  'quizId': instance.quizId,
  'format': _$WrongAnswerFormatEnumMap[instance.format]!,
  'content': instance.content,
  'cognitiveType': _$WrongAnswerCognitiveTypeEnumMap[instance.cognitiveType]!,
  'conceptName': instance.conceptName,
  'materialId': instance.materialId,
  'materialTitle': instance.materialTitle,
  'explanation': instance.explanation,
  'sourceQuote': instance.sourceQuote,
  'sourcePageNo': instance.sourcePageNo,
  'options': instance.options,
  'wrongCount': instance.wrongCount,
  'lastWrongAt': instance.lastWrongAt.toIso8601String(),
};

const _$WrongAnswerFormatEnumMap = {
  WrongAnswerFormat.multipleChoice: 'MULTIPLE_CHOICE',
  WrongAnswerFormat.ox: 'OX',
  WrongAnswerFormat.$unknown: r'$unknown',
};

const _$WrongAnswerCognitiveTypeEnumMap = {
  WrongAnswerCognitiveType.remember: 'REMEMBER',
  WrongAnswerCognitiveType.understand: 'UNDERSTAND',
  WrongAnswerCognitiveType.apply: 'APPLY',
  WrongAnswerCognitiveType.analyze: 'ANALYZE',
  WrongAnswerCognitiveType.evaluate: 'EVALUATE',
  WrongAnswerCognitiveType.$unknown: r'$unknown',
};
