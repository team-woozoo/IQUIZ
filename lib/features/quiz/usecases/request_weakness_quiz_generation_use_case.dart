import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_options_entity.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository.dart';

/// 반환된 jobId로 기존 WatchGenerationJobUseCase를 구독
/// 약점 퀴즈의 문제 수(5개)는 서버가 결정
final class RequestWeaknessQuizGenerationUseCase {
  const RequestWeaknessQuizGenerationUseCase(this.repository);
  final QuizRepository repository;

  Future<Result<int>> call({
    required int conceptId,
    required QuizGenerationOptionsEntity options,
  }) {
    if (conceptId <= 0) {
      return Future.value(
        Result.failure(const FormatException('개념 ID를 확인해 주세요.')),
      );
    }
    return repository.requestWeaknessQuizGeneration(
      conceptId: conceptId,
      options: options,
    );
  }
}
