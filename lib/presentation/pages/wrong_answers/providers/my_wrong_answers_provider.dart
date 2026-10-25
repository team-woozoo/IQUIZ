import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/features/quiz/repositories/entities/wrong_answer_entity.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_wrong_answers_provider.g.dart';

Duration? _noRetry(int retryCount, Object error) => null;

@Riverpod(retry: _noRetry)
Future<List<WrongAnswerEntity>> myWrongAnswers(Ref ref) async {
  final userId = ref.watch(
    userAuthProvider.select(
      (auth) => auth.status == AuthStatus.authenticated ? auth.user?.id : null,
    ),
  );
  if (userId == null) return const [];
  final result = await ref.watch(getMyWrongAnswersUseCaseProvider)();
  return result.fold(
    onSuccess: (items) => items,
    onFailure: (error) => throw error,
  );
}
