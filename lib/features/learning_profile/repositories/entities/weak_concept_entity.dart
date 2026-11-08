import 'package:iquiz/core/validation/learning_statistics_validator.dart';
import 'package:iquiz/features/learning_profile/data_source/remote/models/weak_concept_model.dart';

final class WeakConceptEntity {
  const WeakConceptEntity({
    required this.conceptId,
    required this.conceptName,
    required this.materialId,
    required this.materialTitle,
    required this.answeredCount,
    required this.correctAnswerCount,
    required this.accuracy,
  });

  factory WeakConceptEntity.fromModel(WeakConceptModel model) {
    LearningStatisticsValidator.validateAnswers(
      answeredCount: model.answeredCount,
      correctCount: model.correctAnswerCount,
      accuracy: model.accuracy,
    );
    if (model.answeredCount == 0) {
      throw const FormatException('취약 개념의 풀이 수가 올바르지 않습니다.');
    }
    return WeakConceptEntity(
      conceptId: model.conceptId,
      conceptName: model.conceptName,
      materialId: model.materialId,
      materialTitle: model.materialTitle,
      answeredCount: model.answeredCount,
      correctAnswerCount: model.correctAnswerCount,
      accuracy: model.accuracy,
    );
  }

  final int conceptId;
  final String conceptName;

  /// 같은 이름이라도 자료가 다르면 다른 개념
  final int materialId;
  final String materialTitle;

  /// 같은 문제의 반복 풀이는 최근 답안 하나로 집계
  final int answeredCount;
  final int correctAnswerCount;

  /// 0~1 범위의 정답률
  final double accuracy;
}
