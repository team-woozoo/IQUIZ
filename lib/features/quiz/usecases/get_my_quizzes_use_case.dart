import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_summary_entity.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository.dart';

final class GetMyQuizzesUseCase {
  const GetMyQuizzesUseCase(this.repository);

  final QuizRepository repository;

  Future<Result<List<QuizSummaryEntity>>> call({int? materialId}) {
    if (materialId != null && materialId <= 0) {
      return Future.value(
        Result.failure(const FormatException('자료 ID를 확인해 주세요.')),
      );
    }
    return repository.getMyQuizzes(materialId: materialId);
  }
}
