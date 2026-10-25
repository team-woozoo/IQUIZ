import 'dart:async';

import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_submission_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/wrong_answer_entity.dart';
import 'package:iquiz/presentation/pages/home/providers/my_weak_concepts_provider.dart';
import 'package:iquiz/presentation/pages/profile/providers/my_cognitive_type_scores_provider.dart';
import 'package:iquiz/presentation/pages/wrong_answers/providers/my_wrong_answers_provider.dart';
import 'package:iquiz/presentation/providers/material/material_providers.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wrong_answer_review_provider.g.dart';

Duration? _noRetry(int retryCount, Object error) => null;

@Riverpod(retry: _noRetry)
class WrongAnswerReview extends _$WrongAnswerReview {
  @override
  FutureOr<QuizSubmissionEntity?> build(int questionId) {
    ref.watch(userAuthProvider.select((auth) => auth.user?.id));
    return null;
  }

  Future<QuizSubmissionEntity?> submit({
    required WrongAnswerEntity question,
    required int optionId,
  }) async {
    // 응답 유실도 재기록 가능성이 있으므로 같은 화면에서는 재전송하지 않음
    if (state.isLoading || state.hasError) return null;
    if (state.asData?.value case final QuizSubmissionEntity submitted) {
      return submitted;
    }
    if (question.questionId != questionId ||
        !question.options.any((option) => option.optionId == optionId)) {
      state = AsyncError(
        const FormatException('복습할 문제와 선택한 보기를 확인해 주세요.'),
        StackTrace.current,
      );
      return null;
    }
    final keepAlive = ref.keepAlive();
    final userId = ref.read(userAuthProvider).user?.id;
    state = const AsyncLoading();
    try {
      final result = await ref.read(submitWrongAnswerReviewUseCaseProvider)(
        answers: [QuizAnswerEntity(questionId: questionId, optionId: optionId)],
      );
      if (!ref.mounted || ref.read(userAuthProvider).user?.id != userId) {
        return null;
      }
      final submission = result.fold(
        onSuccess: (value) => value,
        onFailure: (error) => throw error,
      );
      if (submission.totalCount != 1 ||
          submission.results.length != 1 ||
          submission.results.single.questionId != questionId) {
        throw const FormatException('복습 채점 결과의 문제가 일치하지 않습니다.');
      }
      ref.invalidate(myWeakConceptsProvider);
      ref.invalidate(myCognitiveTypeScoresProvider);
      invalidateMaterialData(ref, materialId: question.materialId);
      state = AsyncData(submission);
      return submission;
    } catch (error, stackTrace) {
      if (ref.mounted && ref.read(userAuthProvider).user?.id == userId) {
        state = AsyncError(error, stackTrace);
      }
      return null;
    } finally {
      // 응답을 잃은 경우에도 서버에 반영됐을 수 있으므로 목록을 다시 확인
      if (ref.mounted && ref.read(userAuthProvider).user?.id == userId) {
        ref.invalidate(myWrongAnswersProvider);
      }
      keepAlive.close();
    }
  }
}
