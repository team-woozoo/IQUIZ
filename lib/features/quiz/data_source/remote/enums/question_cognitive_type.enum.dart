import 'package:json_annotation/json_annotation.dart';

///
/// 문제의 사고 수준
///
@JsonEnum()
enum QuestionCognitiveType {
  @JsonValue('REMEMBER')
  remember('REMEMBER'),
  @JsonValue('UNDERSTAND')
  understand('UNDERSTAND'),
  @JsonValue('APPLY')
  apply('APPLY'),
  @JsonValue('ANALYZE')
  analyze('ANALYZE'),
  @JsonValue('EVALUATE')
  evaluate('EVALUATE'),
  $unknown(null);

  const QuestionCognitiveType(this.json);

  factory QuestionCognitiveType.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();
  static List<QuestionCognitiveType> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
