import 'package:iquiz/features/learning_profile/data_source/remote/enums/cognitive_type_score_type.enum.dart';
import 'package:iquiz/features/learning_profile/data_source/remote/models/cognitive_type_score_model.dart';
import 'package:iquiz/features/learning_profile/data_source/remote/models/weak_concept_model.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/cognitive_type_score_entity.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/weak_concept_entity.dart';

extension WeakConceptMapper on WeakConceptModel {
  WeakConceptEntity toEntity() {
    _validateScore(answeredCount, correctAnswerCount, accuracy);
    if (answeredCount == 0) {
      throw const FormatException('취약 개념의 풀이 수가 올바르지 않습니다.');
    }
    return WeakConceptEntity(
      conceptId: conceptId,
      conceptName: conceptName,
      materialId: materialId,
      materialTitle: materialTitle,
      answeredCount: answeredCount,
      correctAnswerCount: correctAnswerCount,
      accuracy: accuracy,
    );
  }
}

extension CognitiveTypeScoreMapper on CognitiveTypeScoreModel {
  CognitiveTypeScoreEntity toEntity() {
    _validateScore(answeredCount, correctAnswerCount, accuracy);
    if ((answeredCount == 0) != (accuracy == null)) {
      throw const FormatException('인지 유형별 정답률의 미풀이 상태가 올바르지 않습니다.');
    }
    return CognitiveTypeScoreEntity(
      cognitiveType: switch (cognitiveType) {
        CognitiveTypeScoreType.remember => .remember,
        CognitiveTypeScoreType.understand => .understand,
        CognitiveTypeScoreType.apply => .apply,
        CognitiveTypeScoreType.analyze => .analyze,
        CognitiveTypeScoreType.evaluate => .evaluate,
        CognitiveTypeScoreType.$unknown => throw const FormatException(
          '지원하지 않는 인지 유형입니다.',
        ),
      },
      answeredCount: answeredCount,
      correctAnswerCount: correctAnswerCount,
      accuracy: accuracy,
      isEnoughData: isEnoughData,
    );
  }
}

void _validateScore(
  int answeredCount,
  int correctAnswerCount,
  double? accuracy,
) {
  if (answeredCount < 0 ||
      correctAnswerCount < 0 ||
      correctAnswerCount > answeredCount ||
      (accuracy != null &&
          (!accuracy.isFinite || accuracy < 0 || accuracy > 1))) {
    throw const FormatException('학습 분석 집계가 올바르지 않습니다.');
  }
}
