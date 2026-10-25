import 'package:json_annotation/json_annotation.dart';

part 'quiz_last_submission_model.g.dart';

///
/// 최근 퀴즈 제출 기록
///
@JsonSerializable()
class QuizLastSubmissionModel {
  const QuizLastSubmissionModel({
    required this.correctCount,
    required this.submittedAt,
  });

  factory QuizLastSubmissionModel.fromJson(Map<String, Object?> json) =>
      _$QuizLastSubmissionModelFromJson(json);

  final int correctCount;
  final DateTime submittedAt;

  Map<String, Object?> toJson() => _$QuizLastSubmissionModelToJson(this);
}
