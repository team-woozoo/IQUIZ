import 'package:json_annotation/json_annotation.dart';

///
/// 퀴즈 생성 요청 난이도
///
@JsonEnum()
enum QuizGenerationDifficulty {
  @JsonValue('EASY')
  easy('EASY'),
  @JsonValue('NORMAL')
  normal('NORMAL'),
  @JsonValue('HARD')
  hard('HARD'),
  $unknown(null);

  const QuizGenerationDifficulty(this.json);

  factory QuizGenerationDifficulty.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();
  static List<QuizGenerationDifficulty> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
