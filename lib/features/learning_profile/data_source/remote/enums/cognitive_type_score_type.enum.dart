import 'package:json_annotation/json_annotation.dart';

///
/// 학습 분석 응답의 인지 유형
///
@JsonEnum()
enum CognitiveTypeScoreType {
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

  const CognitiveTypeScoreType(this.json);

  factory CognitiveTypeScoreType.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();
  static List<CognitiveTypeScoreType> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
