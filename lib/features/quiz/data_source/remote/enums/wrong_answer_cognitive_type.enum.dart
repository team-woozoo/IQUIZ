import 'package:json_annotation/json_annotation.dart';

///
/// 오답 문제의 인지 유형
///
@JsonEnum()
enum WrongAnswerCognitiveType {
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

  const WrongAnswerCognitiveType(this.json);

  factory WrongAnswerCognitiveType.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();
  static List<WrongAnswerCognitiveType> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
