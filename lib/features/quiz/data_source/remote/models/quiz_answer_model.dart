import 'package:iquiz/features/quiz/repositories/entities/quiz_answer_entity.dart';

import 'package:json_annotation/json_annotation.dart';

part 'quiz_answer_model.g.dart';

///
/// 퀴즈 제출 답안
///
@JsonSerializable(explicitToJson: true)
class QuizAnswerModel {
  const QuizAnswerModel({required this.questionId, required this.optionId});

  factory QuizAnswerModel.fromEntity(QuizAnswerEntity entity) =>
      QuizAnswerModel(questionId: entity.questionId, optionId: entity.optionId);

  factory QuizAnswerModel.fromJson(Map<String, Object?> json) =>
      _$QuizAnswerModelFromJson(json);

  final int questionId;
  final int optionId;

  Map<String, Object?> toJson() => _$QuizAnswerModelToJson(this);
}
