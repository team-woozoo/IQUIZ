import 'package:json_annotation/json_annotation.dart';

import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_generation_difficulty.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_generation_format.enum.dart';

part 'quiz_generation_options_model.g.dart';

///
/// 퀴즈 생성 옵션
///
@JsonSerializable()
class QuizGenerationOptionsModel {
  const QuizGenerationOptionsModel({
    required this.format,
    required this.difficulty,
  });

  factory QuizGenerationOptionsModel.fromJson(Map<String, Object?> json) =>
      _$QuizGenerationOptionsModelFromJson(json);

  final QuizGenerationFormat format;
  final QuizGenerationDifficulty difficulty;

  Map<String, Object?> toJson() => _$QuizGenerationOptionsModelToJson(this);
}
