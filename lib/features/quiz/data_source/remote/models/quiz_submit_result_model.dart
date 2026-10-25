import 'package:json_annotation/json_annotation.dart';

import 'quiz_question_result_model.dart';

part 'quiz_submit_result_model.g.dart';

///
/// 퀴즈 제출 채점 결과
///
@JsonSerializable()
class QuizSubmitResultModel {
  const QuizSubmitResultModel({
    required this.submissionId,
    required this.correctCount,
    required this.totalCount,
    required this.results,
  });

  factory QuizSubmitResultModel.fromJson(Map<String, Object?> json) =>
      _$QuizSubmitResultModelFromJson(json);

  final int submissionId;
  final int correctCount;
  final int totalCount;
  final List<QuizQuestionResultModel> results;

  Map<String, Object?> toJson() => _$QuizSubmitResultModelToJson(this);
}
