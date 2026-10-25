import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/quiz/repositories/entities/material_concept_entity.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository.dart';

final class GetMyMaterialConceptsUseCase {
  const GetMyMaterialConceptsUseCase(this.repository);
  final QuizRepository repository;

  Future<Result<List<MaterialConceptEntity>>> call({required int materialId}) {
    if (materialId <= 0) {
      return Future.value(
        Result.failure(const FormatException('자료 ID를 확인해 주세요.')),
      );
    }
    return repository.getMyMaterialConcepts(materialId: materialId);
  }
}
