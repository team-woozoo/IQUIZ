import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/cognitive_type_score_entity.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/weak_concept_entity.dart';

abstract interface class LearningProfileRepository {
  /// 내 자료별 취약 개념과 최근 답안 기준 풀이 수·정답 수·정답률을 조회
  Future<Result<List<WeakConceptEntity>>> getMyWeakConcepts();

  /// 내 인지 유형별 풀이 수·정답 수·정답률과 분석 데이터 충분 여부를 조회
  Future<Result<List<CognitiveTypeScoreEntity>>> getMyCognitiveTypeScores();
}
