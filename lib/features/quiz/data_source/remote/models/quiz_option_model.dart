import 'package:json_annotation/json_annotation.dart';

part 'quiz_option_model.g.dart';

///
/// 퀴즈 문제 보기 정보
///
@JsonSerializable()
class QuizOptionModel {
  const QuizOptionModel({
    required this.optionId,
    required this.orderNo,
    required this.content,
    required this.isCorrect,
  });

  factory QuizOptionModel.fromJson(Map<String, Object?> json) =>
      _$QuizOptionModelFromJson(json);

  final int optionId;
  final int orderNo;
  final String content;
  final bool isCorrect;

  Map<String, Object?> toJson() => _$QuizOptionModelToJson(this);
}
