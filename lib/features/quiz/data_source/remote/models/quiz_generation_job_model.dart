import 'package:json_annotation/json_annotation.dart';

import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_job_status.enum.dart';

part 'quiz_generation_job_model.g.dart';

///
/// 퀴즈 생성 작업 진행 정보
///
@JsonSerializable()
class QuizGenerationJobModel {
  const QuizGenerationJobModel({
    required this.jobId,
    required this.status,
    required this.quizId,
    required this.errorCode,
  });

  factory QuizGenerationJobModel.fromJson(Map<String, Object?> json) =>
      _$QuizGenerationJobModelFromJson(json);

  final int jobId;
  final QuizJobStatus status;

  final int? quizId;

  final String? errorCode;

  Map<String, Object?> toJson() => _$QuizGenerationJobModelToJson(this);
}
