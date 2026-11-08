import 'package:json_annotation/json_annotation.dart';

part 'quiz_question_result_model.g.dart';

///
/// 문제별 채점 결과
///
@JsonSerializable(explicitToJson: true)
class QuizQuestionResultModel {
  const QuizQuestionResultModel({
    required this.questionId,
    required this.correct,
  });

  factory QuizQuestionResultModel.fromJson(Map<String, Object?> json) =>
      _$QuizQuestionResultModelFromJson(json);

  final int questionId;
  final bool correct;

  Map<String, Object?> toJson() => _$QuizQuestionResultModelToJson(this);
}
