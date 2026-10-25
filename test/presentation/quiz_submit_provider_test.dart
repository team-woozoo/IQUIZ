import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_submission_entity.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/providers/quiz_route_arg.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/providers/quiz_submit_provider.dart';

import '../support/quiz_fakes.dart';

void main() {
  late FakeQuizRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeQuizRepository();
    container = ProviderContainer(
      overrides: [
        quizRepositoryProvider.overrideWithValue(repository),
        quizRouteArgProvider.overrideWithValue(7),
      ],
    );
    container.listen(quizSubmitProvider, (_, _) {});
  });
  tearDown(() => container.dispose());

  test('중복 제출을 막고 성공 결과는 재사용하며 다시 풀기 때만 초기화한다', () async {
    final pending = Completer<Result<QuizSubmissionEntity>>();
    repository.onSubmit = () => pending.future;
    final notifier = container.read(quizSubmitProvider.notifier);
    final first = notifier.submit(quiz: testQuiz, answers: testAnswers);
    expect(container.read(quizSubmitProvider).isLoading, isTrue);
    expect(await notifier.submit(quiz: testQuiz, answers: testAnswers), isNull);
    expect(repository.submitCount, 1);
    pending.complete(Result.success(testSubmission));
    expect(await first, same(testSubmission));
    expect(
      await notifier.submit(quiz: testQuiz, answers: testAnswers),
      same(testSubmission),
    );
    expect(repository.submitCount, 1);
    notifier.reset();
    expect(
      await notifier.submit(quiz: testQuiz, answers: testAnswers),
      same(testSubmission),
    );
    expect(repository.submitCount, 2);
  });

  test('실패 시 자동으로 재제출하지 않고 사용자 재시도만 허용한다', () async {
    repository.onSubmit = () async =>
        Result.failure(const InvalidSubmissionException());
    final notifier = container.read(quizSubmitProvider.notifier);
    expect(await notifier.submit(quiz: testQuiz, answers: testAnswers), isNull);
    expect(
      container.read(quizSubmitProvider).error,
      isA<InvalidSubmissionException>(),
    );
    await Future<void>.delayed(Duration.zero);
    expect(repository.submitCount, 1);
    repository.onSubmit = null;
    expect(
      await notifier.submit(quiz: testQuiz, answers: testAnswers),
      same(testSubmission),
    );
    expect(repository.submitCount, 2);
  });
}
