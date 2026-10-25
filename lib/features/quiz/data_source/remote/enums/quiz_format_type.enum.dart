import 'package:json_annotation/json_annotation.dart';

///
/// 조회한 퀴즈 형식
///
@JsonEnum()
enum QuizFormatType {
  @JsonValue('MULTIPLE_CHOICE')
  multipleChoice('MULTIPLE_CHOICE'),
  @JsonValue('OX')
  ox('OX'),
  $unknown(null);

  const QuizFormatType(this.json);

  factory QuizFormatType.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();
  static List<QuizFormatType> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
