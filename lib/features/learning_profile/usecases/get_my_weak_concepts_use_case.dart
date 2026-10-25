import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/weak_concept_entity.dart';
import 'package:iquiz/features/learning_profile/repositories/learning_profile_repository.dart';

final class GetMyWeakConceptsUseCase {
  const GetMyWeakConceptsUseCase(this.repository);

  final LearningProfileRepository repository;

  Future<Result<List<WeakConceptEntity>>> call() =>
      repository.getMyWeakConcepts();
}
