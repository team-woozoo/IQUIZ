import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/quiz/repositories/entities/wrong_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository.dart';

final class GetMyWrongAnswersUseCase {
  const GetMyWrongAnswersUseCase(this.repository);

  final QuizRepository repository;

  Future<Result<List<WrongAnswerEntity>>> call() =>
      repository.getMyWrongAnswers();
}
