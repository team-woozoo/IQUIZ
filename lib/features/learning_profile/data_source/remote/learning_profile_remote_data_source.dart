import 'package:iquiz/features/learning_profile/data_source/remote/models/cognitive_type_score_model.dart';
import 'package:iquiz/features/learning_profile/data_source/remote/models/weak_concept_model.dart';

abstract interface class LearningProfileRemoteDataSource {
  /// 서버가 정렬한 자료별 취약 개념을 조회
  Future<List<WeakConceptModel>> getMyWeakConcepts();

  /// 기억·이해·적용·분석·평가 유형별 최신 답안 집계를 조회
  Future<List<CognitiveTypeScoreModel>> getMyCognitiveTypeScores();
}
