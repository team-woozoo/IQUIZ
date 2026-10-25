// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizSummaryModel _$QuizSummaryModelFromJson(Map<String, dynamic> json) =>
    QuizSummaryModel(
      quizId: (json['quizId'] as num).toInt(),
      materialId: (json['materialId'] as num?)?.toInt(),
      materialTitle: json['materialTitle'] as String?,
      format: QuizSummaryFormat.fromJson(json['format'] as String),
      difficulty: QuizSummaryDifficulty.fromJson(json['difficulty'] as String),
      questionCount: (json['questionCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      submissionCount: (json['submissionCount'] as num).toInt(),
      lastSubmission: json['lastSubmission'] == null
          ? null
          : QuizLastSubmissionModel.fromJson(
              json['lastSubmission'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$QuizSummaryModelToJson(QuizSummaryModel instance) =>
    <String, dynamic>{
      'quizId': instance.quizId,
      'materialId': instance.materialId,
      'materialTitle': instance.materialTitle,
      'format': _$QuizSummaryFormatEnumMap[instance.format]!,
      'difficulty': _$QuizSummaryDifficultyEnumMap[instance.difficulty]!,
      'questionCount': instance.questionCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'submissionCount': instance.submissionCount,
      'lastSubmission': instance.lastSubmission,
    };

const _$QuizSummaryFormatEnumMap = {
  QuizSummaryFormat.multipleChoice: 'MULTIPLE_CHOICE',
  QuizSummaryFormat.ox: 'OX',
  QuizSummaryFormat.$unknown: r'$unknown',
};

const _$QuizSummaryDifficultyEnumMap = {
  QuizSummaryDifficulty.easy: 'EASY',
  QuizSummaryDifficulty.normal: 'NORMAL',
  QuizSummaryDifficulty.hard: 'HARD',
  QuizSummaryDifficulty.$unknown: r'$unknown',
};
