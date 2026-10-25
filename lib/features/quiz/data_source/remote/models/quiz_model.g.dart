// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizModel _$QuizModelFromJson(Map<String, dynamic> json) => QuizModel(
  quizId: (json['quizId'] as num).toInt(),
  materialId: (json['materialId'] as num?)?.toInt(),
  format: QuizFormatType.fromJson(json['format'] as String),
  difficulty: QuizDifficultyLevel.fromJson(json['difficulty'] as String),
  questions: (json['questions'] as List<dynamic>)
      .map((e) => QuizQuestionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$QuizModelToJson(QuizModel instance) => <String, dynamic>{
  'quizId': instance.quizId,
  'materialId': instance.materialId,
  'format': _$QuizFormatTypeEnumMap[instance.format]!,
  'difficulty': _$QuizDifficultyLevelEnumMap[instance.difficulty]!,
  'questions': instance.questions,
};

const _$QuizFormatTypeEnumMap = {
  QuizFormatType.multipleChoice: 'MULTIPLE_CHOICE',
  QuizFormatType.ox: 'OX',
  QuizFormatType.$unknown: r'$unknown',
};

const _$QuizDifficultyLevelEnumMap = {
  QuizDifficultyLevel.easy: 'EASY',
  QuizDifficultyLevel.normal: 'NORMAL',
  QuizDifficultyLevel.hard: 'HARD',
  QuizDifficultyLevel.$unknown: r'$unknown',
};
