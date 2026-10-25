import 'package:json_annotation/json_annotation.dart';

import 'quiz_answer_model.dart';

part 'quiz_submit_model.g.dart';

///
/// 퀴즈 답안 제출 요청
///
@JsonSerializable()
class QuizSubmitModel {
  const QuizSubmitModel({required this.answers});

  factory QuizSubmitModel.fromJson(Map<String, Object?> json) =>
      _$QuizSubmitModelFromJson(json);

  final List<QuizAnswerModel> answers;

  Map<String, Object?> toJson() => _$QuizSubmitModelToJson(this);
}
