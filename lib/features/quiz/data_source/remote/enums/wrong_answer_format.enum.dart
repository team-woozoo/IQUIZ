import 'package:json_annotation/json_annotation.dart';

///
/// 오답 문제 형식
///
@JsonEnum()
enum WrongAnswerFormat {
  @JsonValue('MULTIPLE_CHOICE')
  multipleChoice('MULTIPLE_CHOICE'),
  @JsonValue('OX')
  ox('OX'),
  $unknown(null);

  const WrongAnswerFormat(this.json);

  factory WrongAnswerFormat.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();
  static List<WrongAnswerFormat> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
