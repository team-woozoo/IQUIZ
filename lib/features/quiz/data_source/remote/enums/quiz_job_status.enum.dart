import 'package:json_annotation/json_annotation.dart';

///
/// 서버 퀴즈 생성 작업 상태
///
@JsonEnum()
enum QuizJobStatus {
  @JsonValue('PENDING')
  pending('PENDING'),
  @JsonValue('PROCESSING')
  processing('PROCESSING'),
  @JsonValue('DONE')
  done('DONE'),
  @JsonValue('FAILED')
  failed('FAILED'),

  $unknown(null);

  const QuizJobStatus(this.json);

  factory QuizJobStatus.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  static List<QuizJobStatus> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
