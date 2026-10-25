import 'package:json_annotation/json_annotation.dart';

///
/// 조회한 퀴즈 난이도
///
@JsonEnum()
enum QuizDifficultyLevel {
  @JsonValue('EASY')
  easy('EASY'),
  @JsonValue('NORMAL')
  normal('NORMAL'),
  @JsonValue('HARD')
  hard('HARD'),
  $unknown(null);

  const QuizDifficultyLevel(this.json);

  factory QuizDifficultyLevel.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();
  static List<QuizDifficultyLevel> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
