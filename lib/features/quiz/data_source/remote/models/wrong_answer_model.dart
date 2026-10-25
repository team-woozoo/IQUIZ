import 'package:json_annotation/json_annotation.dart';

import 'quiz_option_model.dart';

import 'package:iquiz/features/quiz/data_source/remote/enums/wrong_answer_cognitive_type.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/wrong_answer_format.enum.dart';

part 'wrong_answer_model.g.dart';

///
/// 미해결 오답 정보
///
@JsonSerializable()
class WrongAnswerModel {
  const WrongAnswerModel({
    required this.questionId,
    required this.quizId,
    required this.format,
    required this.content,
    required this.cognitiveType,
    required this.conceptName,
    required this.materialId,
    required this.materialTitle,
    required this.explanation,
    required this.sourceQuote,
    required this.sourcePageNo,
    required this.options,
    required this.wrongCount,
    required this.lastWrongAt,
  });

  factory WrongAnswerModel.fromJson(Map<String, Object?> json) =>
      _$WrongAnswerModelFromJson(json);

  final int questionId;
  final int quizId;
  final WrongAnswerFormat format;
  final String content;
  final WrongAnswerCognitiveType cognitiveType;
  final String conceptName;

  final int materialId;
  final String materialTitle;
  final String explanation;
  final String sourceQuote;

  final int? sourcePageNo;

  final List<QuizOptionModel> options;

  final int wrongCount;

  final DateTime lastWrongAt;

  Map<String, Object?> toJson() => _$WrongAnswerModelToJson(this);
}
