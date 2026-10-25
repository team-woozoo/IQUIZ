import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_submission_entity.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository.dart';

final class SubmitQuizUseCase {
  const SubmitQuizUseCase(this.repository);

  final QuizRepository repository;

  Future<Result<QuizSubmissionEntity>> call({
    required int quizId,
    required List<QuizAnswerEntity> answers,
  }) {
    if (quizId <= 0 || answers.isEmpty) {
      return Future.value(
        Result.failure(const FormatException('제출할 퀴즈와 답안을 확인해 주세요.')),
      );
    }
    if (answers.any(
          (answer) => answer.questionId <= 0 || answer.optionId <= 0,
        ) ||
        answers.map((answer) => answer.questionId).toSet().length !=
            answers.length) {
      return Future.value(
        Result.failure(const FormatException('문제마다 답안을 하나씩 선택해 주세요.')),
      );
    }
    return repository.submitQuiz(quizId: quizId, answers: answers);
  }
}
