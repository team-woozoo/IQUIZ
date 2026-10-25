import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/quiz/repositories/entities/study_material_entity.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository.dart';

final class GetMyMaterialsUseCase {
  const GetMyMaterialsUseCase(this.repository);
  final QuizRepository repository;

  Future<Result<List<StudyMaterialEntity>>> call() {
    return repository.getMyMaterials();
  }
}
