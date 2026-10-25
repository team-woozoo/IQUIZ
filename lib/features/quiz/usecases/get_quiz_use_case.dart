import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_entity.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository.dart';

final class GetQuizUseCase {
  const GetQuizUseCase(this.repository);

  final QuizRepository repository;

  Future<Result<QuizEntity>> call({required int quizId}) =>
      repository.getQuiz(quizId: quizId);
}
