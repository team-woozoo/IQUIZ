import 'package:iquiz/features/quiz/repositories/entities/quiz_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_submission_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quiz_result_route_arg.g.dart';

final class QuizResultRouteArg {
  QuizResultRouteArg({
    required this.quiz,
    required this.submission,
    required List<QuizAnswerEntity> answers,
    this.materialTitle,
  }) : answers = List.unmodifiable(answers);

  final QuizEntity quiz;
  final QuizSubmissionEntity submission;
  final List<QuizAnswerEntity> answers;
  final String? materialTitle;
}

@Riverpod(dependencies: [])
QuizResultRouteArg? quizResultRouteArg(Ref ref) {
  throw StateError('QuizResultPage에서 결과 정보를 주입해야 합니다.');
}
