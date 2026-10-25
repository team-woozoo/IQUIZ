import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/quiz/repositories/entities/study_material_entity.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository.dart';

final class GetMyMaterialUseCase {
  const GetMyMaterialUseCase(this.repository);
  final QuizRepository repository;

  Future<Result<StudyMaterialEntity>> call({required int materialId}) {
    if (materialId <= 0) {
      return Future.value(
        Result.failure(const FormatException('자료 ID를 확인해 주세요.')),
      );
    }
    return repository.getMyMaterial(materialId: materialId);
  }
}
