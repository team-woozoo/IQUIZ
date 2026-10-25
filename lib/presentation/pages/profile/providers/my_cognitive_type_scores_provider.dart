import 'package:iquiz/app/di/learning_profile/learning_profile.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/cognitive_type_score_entity.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_cognitive_type_scores_provider.g.dart';

Duration? _noRetry(int retryCount, Object error) => null;

@Riverpod(retry: _noRetry)
Future<List<CognitiveTypeScoreEntity>> myCognitiveTypeScores(Ref ref) async {
  final userId = ref.watch(
    userAuthProvider.select(
      (auth) => auth.status == AuthStatus.authenticated ? auth.user?.id : null,
    ),
  );
  if (userId == null) return const [];
  final result = await ref.watch(getMyCognitiveTypeScoresUseCaseProvider)();
  return result.fold(
    onSuccess: (scores) => scores,
    onFailure: (error) => throw error,
  );
}
