import 'package:json_annotation/json_annotation.dart';

///
/// 자료 개념의 서버 학습 상태
///
@JsonEnum()
enum MaterialConceptStatus {
  @JsonValue('WEAK')
  weak('WEAK'),
  @JsonValue('GOOD')
  good('GOOD'),
  @JsonValue('PERFECT')
  perfect('PERFECT'),
  @JsonValue('UNCHECKED')
  unchecked('UNCHECKED'),
  $unknown(null);

  const MaterialConceptStatus(this.json);

  factory MaterialConceptStatus.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();
  static List<MaterialConceptStatus> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
