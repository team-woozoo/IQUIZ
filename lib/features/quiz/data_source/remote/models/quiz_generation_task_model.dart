import 'package:json_annotation/json_annotation.dart';

part 'quiz_generation_task_model.g.dart';

///
/// 퀴즈 생성 요청 접수 결과
///
@JsonSerializable()
class QuizGenerationTaskModel {
  const QuizGenerationTaskModel({required this.jobId});

  factory QuizGenerationTaskModel.fromJson(Map<String, Object?> json) =>
      _$QuizGenerationTaskModelFromJson(json);

  final int jobId;

  Map<String, Object?> toJson() => _$QuizGenerationTaskModelToJson(this);
}
