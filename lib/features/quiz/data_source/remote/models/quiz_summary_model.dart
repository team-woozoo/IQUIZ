import 'package:json_annotation/json_annotation.dart';

import 'quiz_last_submission_model.dart';

import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_summary_difficulty.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_summary_format.enum.dart';

part 'quiz_summary_model.g.dart';

///
/// 내 퀴즈 목록 요약 정보
///
@JsonSerializable()
class QuizSummaryModel {
  const QuizSummaryModel({
    required this.quizId,
    required this.materialId,
    required this.materialTitle,
    required this.format,
    required this.difficulty,
    required this.questionCount,
    required this.createdAt,
    required this.submissionCount,
    required this.lastSubmission,
  });

  factory QuizSummaryModel.fromJson(Map<String, Object?> json) =>
      _$QuizSummaryModelFromJson(json);

  final int quizId;

  final int? materialId;

  final String? materialTitle;
  final QuizSummaryFormat format;
  final QuizSummaryDifficulty difficulty;
  final int questionCount;
  final DateTime createdAt;

  final int submissionCount;

  final QuizLastSubmissionModel? lastSubmission;

  Map<String, Object?> toJson() => _$QuizSummaryModelToJson(this);
}
