import 'package:json_annotation/json_annotation.dart';

import 'quiz_option_model.dart';

import 'package:iquiz/features/quiz/data_source/remote/enums/question_cognitive_type.enum.dart';

part 'quiz_question_model.g.dart';

///
/// 퀴즈 문제 정보
///
@JsonSerializable()
class QuizQuestionModel {
  const QuizQuestionModel({
    required this.questionId,
    required this.orderNo,
    required this.content,
    required this.cognitiveType,
    required this.conceptName,
    required this.explanation,
    required this.sourceQuote,
    required this.sourcePageNo,
    required this.options,
  });

  factory QuizQuestionModel.fromJson(Map<String, Object?> json) =>
      _$QuizQuestionModelFromJson(json);

  final int questionId;
  final int orderNo;
  final String content;
  final QuestionCognitiveType cognitiveType;
  final String conceptName;
  final String explanation;
  final String sourceQuote;

  final int? sourcePageNo;
  final List<QuizOptionModel> options;

  Map<String, Object?> toJson() => _$QuizQuestionModelToJson(this);
}
