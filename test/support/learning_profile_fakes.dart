import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/cognitive_type_score_entity.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/weak_concept_entity.dart';
import 'package:iquiz/features/learning_profile/repositories/learning_profile_repository.dart';

const homeWeakConcept = WeakConceptEntity(
  conceptId: 12,
  conceptName: 'TCP 연결 과정',
  materialId: 3,
  materialTitle: '네트워크',
  answeredCount: 10,
  correctAnswerCount: 3,
  accuracy: 0.3,
);

class FakeLearningProfileRepository implements LearningProfileRepository {
  List<WeakConceptEntity> weakConcepts = [];
  List<CognitiveTypeScoreEntity> cognitiveTypeScores = [];
  Future<Result<List<CognitiveTypeScoreEntity>>> Function()?
  onGetCognitiveTypeScores;
  int weakConceptsCount = 0;
  int cognitiveTypeScoresCount = 0;
  Future<Result<List<WeakConceptEntity>>> Function()? onGetWeakConcepts;

  @override
  Future<Result<List<WeakConceptEntity>>> getMyWeakConcepts() async {
    weakConceptsCount++;
    return onGetWeakConcepts == null
        ? Result.success(weakConcepts)
        : await onGetWeakConcepts!();
  }

  @override
  Future<Result<List<CognitiveTypeScoreEntity>>>
  getMyCognitiveTypeScores() async {
    cognitiveTypeScoresCount++;
    return onGetCognitiveTypeScores == null
        ? Result.success(cognitiveTypeScores)
        : await onGetCognitiveTypeScores!();
  }
}
