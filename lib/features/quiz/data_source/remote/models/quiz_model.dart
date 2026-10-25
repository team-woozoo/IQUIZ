import 'package:json_annotation/json_annotation.dart';

import 'quiz_question_model.dart';

import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_difficulty_level.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_format_type.enum.dart';

part 'quiz_model.g.dart';

///
/// 퀴즈 상세 정보
///
@JsonSerializable()
class QuizModel {
  const QuizModel({
    required this.quizId,
    required this.materialId,
    required this.format,
    required this.difficulty,
    required this.questions,
  });

  factory QuizModel.fromJson(Map<String, Object?> json) =>
      _$QuizModelFromJson(json);

  final int quizId;

  final int? materialId;
  final QuizFormatType format;
  final QuizDifficultyLevel difficulty;
  final List<QuizQuestionModel> questions;

  Map<String, Object?> toJson() => _$QuizModelToJson(this);
}
