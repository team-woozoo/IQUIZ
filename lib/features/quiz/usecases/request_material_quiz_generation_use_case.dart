import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_options_entity.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository.dart';

final class RequestMaterialQuizGenerationUseCase {
  const RequestMaterialQuizGenerationUseCase(this.repository);

  final QuizRepository repository;

  Future<Result<int>> call({
    required int materialId,
    required QuizGenerationOptionsEntity options,
  }) {
    if (materialId <= 0) {
      return Future.value(
        Result.failure(const FormatException('자료 ID가 올바르지 않습니다.')),
      );
    }
    return repository.requestMaterialQuizGeneration(
      materialId: materialId,
      options: options,
    );
  }
}
