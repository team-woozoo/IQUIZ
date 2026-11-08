import 'package:iquiz/core/validation/learning_statistics_validator.dart';
import 'package:iquiz/features/learning_profile/data_source/remote/enums/cognitive_type_score_type.enum.dart';
import 'package:iquiz/features/learning_profile/data_source/remote/models/cognitive_type_score_model.dart';
import 'package:iquiz/features/learning_profile/repositories/enums/cognitive_type.enum.dart';

final class CognitiveTypeScoreEntity {
  const CognitiveTypeScoreEntity({
    required this.cognitiveType,
    required this.answeredCount,
    required this.correctAnswerCount,
    required this.accuracy,
    required this.isEnoughData,
  });

  factory CognitiveTypeScoreEntity.fromModel(CognitiveTypeScoreModel model) {
    LearningStatisticsValidator.validateAnswers(
      answeredCount: model.answeredCount,
      correctCount: model.correctAnswerCount,
      accuracy: model.accuracy,
    );
    final validAccuracyPresence = model.answeredCount == 0
        ? model.accuracy == null
        : model.accuracy != null;
    if (!validAccuracyPresence) {
      throw const FormatException('인지 유형별 정답률의 미풀이 상태가 올바르지 않습니다.');
    }
    return CognitiveTypeScoreEntity(
      cognitiveType: switch (model.cognitiveType) {
        CognitiveTypeScoreType.remember => .remember,
        CognitiveTypeScoreType.understand => .understand,
        CognitiveTypeScoreType.apply => .apply,
        CognitiveTypeScoreType.analyze => .analyze,
        CognitiveTypeScoreType.evaluate => .evaluate,
        CognitiveTypeScoreType.$unknown => throw const FormatException(
          '지원하지 않는 인지 유형입니다.',
        ),
      },
      answeredCount: model.answeredCount,
      correctAnswerCount: model.correctAnswerCount,
      accuracy: model.accuracy,
      isEnoughData: model.isEnoughData,
    );
  }

  final CognitiveType cognitiveType;
  final int answeredCount;
  final int correctAnswerCount;

  /// 0~1 범위이며, 이 유형을 풀지 않았으면 null
  final double? accuracy;

  /// 서버가 판단한 집계 데이터 충분성
  final bool isEnoughData;
}
