import 'package:json_annotation/json_annotation.dart';

part 'quiz_answer_model.g.dart';

///
/// 퀴즈 제출 답안
///
@JsonSerializable()
class QuizAnswerModel {
  const QuizAnswerModel({required this.questionId, required this.optionId});

  factory QuizAnswerModel.fromJson(Map<String, Object?> json) =>
      _$QuizAnswerModelFromJson(json);

  final int questionId;
  final int optionId;

  Map<String, Object?> toJson() => _$QuizAnswerModelToJson(this);
}
