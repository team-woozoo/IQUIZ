import 'package:iquiz/core/validation/learning_statistics_validator.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/study_material_model.dart';

/// 자료 전체 문제 기준의 학습 집계. 오답 수에는 미풀이도 포함
final class StudyMaterialEntity {
  const StudyMaterialEntity({
    required this.materialId,
    required this.title,
    required this.originalFilename,
    required this.pageCount,
    required this.createdAt,
    required this.questionCount,
    required this.answeredCount,
    required this.correctCount,
    required this.wrongCount,
    required this.accuracy,
    required this.generating,
  });

  factory StudyMaterialEntity.fromModel(StudyMaterialModel model) {
    LearningStatisticsValidator.validateMaterial(
      questionCount: model.questionCount,
      answeredCount: model.answeredCount,
      correctCount: model.correctCount,
      accuracy: model.accuracy,
    );
    if (model.materialId <= 0 ||
        model.pageCount < 0 ||
        model.wrongCount != model.questionCount - model.correctCount) {
      throw const FormatException('자료 정보 또는 오답 집계가 올바르지 않습니다.');
    }
    return StudyMaterialEntity(
      materialId: model.materialId,
      title: model.title,
      originalFilename: model.originalFilename,
      pageCount: model.pageCount,
      createdAt: model.createdAt,
      questionCount: model.questionCount,
      answeredCount: model.answeredCount,
      correctCount: model.correctCount,
      wrongCount: model.wrongCount,
      accuracy: model.accuracy,
      generating: model.generating,
    );
  }

  final int materialId;
  final String title;
  final String originalFilename;

  /// 글자가 있어 저장된 페이지 수이며, 원본 전체 쪽수와 다를 수 있음
  final int pageCount;
  final DateTime createdAt;
  final int questionCount;
  final int answeredCount;
  final int correctCount;
  final int wrongCount;
  final double? accuracy;
  final bool generating;
}
