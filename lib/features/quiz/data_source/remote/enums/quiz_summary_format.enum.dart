import 'package:json_annotation/json_annotation.dart';

///
/// 퀴즈 목록의 문제 형식
///
@JsonEnum()
enum QuizSummaryFormat {
  @JsonValue('MULTIPLE_CHOICE')
  multipleChoice('MULTIPLE_CHOICE'),
  @JsonValue('OX')
  ox('OX'),
  $unknown(null);

  const QuizSummaryFormat(this.json);

  factory QuizSummaryFormat.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();
  static List<QuizSummaryFormat> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
