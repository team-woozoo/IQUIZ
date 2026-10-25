import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_entity.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/providers/quiz_route_arg.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quiz_detail_provider.g.dart';

@Riverpod(dependencies: [quizRouteArg])
Future<QuizEntity> quizDetail(Ref ref) async {
  final quizId = ref.watch(quizRouteArgProvider);
  if (quizId <= 0) {
    throw const FormatException('퀴즈 주소가 올바르지 않습니다.');
  }
  final result = await ref.read(getQuizUseCaseProvider)(quizId: quizId);
  return result.fold(
    onSuccess: (quiz) => quiz,
    onFailure: (error) => throw error,
  );
}
