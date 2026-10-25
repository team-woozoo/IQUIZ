import 'package:json_annotation/json_annotation.dart';

///
/// 퀴즈 목록의 난이도
///
@JsonEnum()
enum QuizSummaryDifficulty {
  @JsonValue('EASY')
  easy('EASY'),
  @JsonValue('NORMAL')
  normal('NORMAL'),
  @JsonValue('HARD')
  hard('HARD'),
  $unknown(null);

  const QuizSummaryDifficulty(this.json);

  factory QuizSummaryDifficulty.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();
  static List<QuizSummaryDifficulty> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
