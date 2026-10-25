import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_job_entity.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository.dart';

final class WatchGenerationJobUseCase {
  const WatchGenerationJobUseCase(this.repository);

  final QuizRepository repository;

  Stream<Result<QuizGenerationJobEntity>> call({required int jobId}) =>
      repository.watchGenerationJob(jobId: jobId);
}
