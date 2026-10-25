import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/cognitive_type_score_entity.dart';
import 'package:iquiz/features/learning_profile/repositories/learning_profile_repository.dart';

final class GetMyCognitiveTypeScoresUseCase {
  const GetMyCognitiveTypeScoresUseCase(this.repository);

  final LearningProfileRepository repository;

  Future<Result<List<CognitiveTypeScoreEntity>>> call() =>
      repository.getMyCognitiveTypeScores();
}
