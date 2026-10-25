// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_generation_options_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizGenerationOptionsModel _$QuizGenerationOptionsModelFromJson(
  Map<String, dynamic> json,
) => QuizGenerationOptionsModel(
  format: QuizGenerationFormat.fromJson(json['format'] as String),
  difficulty: QuizGenerationDifficulty.fromJson(json['difficulty'] as String),
);

Map<String, dynamic> _$QuizGenerationOptionsModelToJson(
  QuizGenerationOptionsModel instance,
) => <String, dynamic>{
  'format': _$QuizGenerationFormatEnumMap[instance.format]!,
  'difficulty': _$QuizGenerationDifficultyEnumMap[instance.difficulty]!,
};

const _$QuizGenerationFormatEnumMap = {
  QuizGenerationFormat.multipleChoice: 'MULTIPLE_CHOICE',
  QuizGenerationFormat.ox: 'OX',
  QuizGenerationFormat.$unknown: r'$unknown',
};

const _$QuizGenerationDifficultyEnumMap = {
  QuizGenerationDifficulty.easy: 'EASY',
  QuizGenerationDifficulty.normal: 'NORMAL',
  QuizGenerationDifficulty.hard: 'HARD',
  QuizGenerationDifficulty.$unknown: r'$unknown',
};
