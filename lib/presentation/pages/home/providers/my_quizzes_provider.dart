import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_summary_entity.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_quizzes_provider.g.dart';

Duration? _noRetry(int retryCount, Object error) => null;

@Riverpod(retry: _noRetry)
Future<List<QuizSummaryEntity>> myQuizzes(Ref ref) async {
  final userId = ref.watch(
    userAuthProvider.select(
      (auth) => auth.status == AuthStatus.authenticated ? auth.user?.id : null,
    ),
  );
  if (userId == null) return const [];

  final result = await ref.watch(getMyQuizzesUseCaseProvider)();
  return result.fold(
    onSuccess: (quizzes) => quizzes,
    onFailure: (error) => throw error,
  );
}
