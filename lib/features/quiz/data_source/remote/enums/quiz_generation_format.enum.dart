import 'package:json_annotation/json_annotation.dart';

///
/// 퀴즈 생성 요청 형식
///
@JsonEnum()
enum QuizGenerationFormat {
  @JsonValue('MULTIPLE_CHOICE')
  multipleChoice('MULTIPLE_CHOICE'),
  @JsonValue('OX')
  ox('OX'),
  $unknown(null);

  const QuizGenerationFormat(this.json);

  factory QuizGenerationFormat.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();
  static List<QuizGenerationFormat> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
