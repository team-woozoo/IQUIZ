import 'dart:async';

import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_submission_entity.dart';
import 'package:iquiz/presentation/pages/home/providers/my_quizzes_provider.dart';
import 'package:iquiz/presentation/pages/home/providers/my_weak_concepts_provider.dart';
import 'package:iquiz/presentation/pages/profile/providers/my_cognitive_type_scores_provider.dart';
import 'package:iquiz/presentation/providers/material/material_providers.dart';
import 'package:iquiz/presentation/pages/wrong_answers/providers/my_wrong_answers_provider.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/providers/quiz_route_arg.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quiz_submit_provider.g.dart';

Duration? _noRetry(int retryCount, Object error) => null;

@Riverpod(dependencies: [quizRouteArg], retry: _noRetry)
class QuizSubmit extends _$QuizSubmit {
  @override
  FutureOr<QuizSubmissionEntity?> build() {
    ref.watch(quizRouteArgProvider);
    return null;
  }

  Future<QuizSubmissionEntity?> submit({
    required QuizEntity quiz,
    required List<QuizAnswerEntity> answers,
  }) async {
    if (state.isLoading) return null;
    final submitted = state.asData?.value;
    if (submitted != null) return submitted;

    final quizId = ref.read(quizRouteArgProvider);
    state = const AsyncLoading();
    try {
      if (quiz.quizId != quizId) {
        throw const FormatException('제출할 퀴즈 정보가 일치하지 않습니다.');
      }
      final result = await ref.read(submitQuizUseCaseProvider)(
        quizId: quizId,
        answers: answers,
      );
      if (!ref.mounted) return null;
      final submission = result.fold(
        onSuccess: (value) => value,
        onFailure: (error) => throw error,
      );
      final questionIds = quiz.questions
          .map((question) => question.questionId)
          .toSet();
      if (submission.totalCount != questionIds.length ||
          submission.results.any(
            (result) => !questionIds.contains(result.questionId),
          )) {
        throw const FormatException('채점 결과의 문제 정보가 일치하지 않습니다.');
      }
      ref.invalidate(myQuizzesProvider);
      ref.invalidate(myWrongAnswersProvider);
      ref.invalidate(myWeakConceptsProvider);
      ref.invalidate(myCognitiveTypeScoresProvider);
      // 자료 없는 약점 퀴즈도 원본 개념의 통계에 영향을 줌
      invalidateMaterialData(ref, materialId: quiz.materialId);
      state = AsyncData(submission);
      return submission;
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(error, stackTrace);
      return null;
    }
  }

  void reset() {
    if (state.isLoading) return;
    state = const AsyncData(null);
  }
}
