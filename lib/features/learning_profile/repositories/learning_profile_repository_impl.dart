import 'package:iquiz/app/network/api_error.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/learning_profile/data_source/remote/learning_profile_remote_data_source.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/cognitive_type_score_entity.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/weak_concept_entity.dart';
import 'package:iquiz/features/learning_profile/repositories/learning_profile_repository.dart';
import 'package:iquiz/features/learning_profile/repositories/mappers/learning_profile_mapper.dart';

final class LearningProfileRepositoryImpl implements LearningProfileRepository {
  const LearningProfileRepositoryImpl(this._remote);

  final LearningProfileRemoteDataSource _remote;

  @override
  Future<Result<List<WeakConceptEntity>>> getMyWeakConcepts() async {
    try {
      final response = await _remote.getMyWeakConcepts();
      return Result.success(
        List.unmodifiable(response.map((model) => model.toEntity())),
      );
    } on Exception catch (error) {
      return Result.failure(mapApiError(error));
    }
  }

  @override
  Future<Result<List<CognitiveTypeScoreEntity>>>
  getMyCognitiveTypeScores() async {
    try {
      final response = await _remote.getMyCognitiveTypeScores();
      return Result.success(
        List.unmodifiable(response.map((model) => model.toEntity())),
      );
    } on Exception catch (error) {
      return Result.failure(mapApiError(error));
    }
  }
}
