import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/di/learning_profile/learning_profile.dart';
import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/auth/repositories/entities/user_entity.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/weak_concept_entity.dart';
import 'package:iquiz/presentation/pages/home/providers/my_weak_concepts_provider.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/providers/quiz_route_arg.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/providers/quiz_submit_provider.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';

import '../support/home_fakes.dart';
import '../support/learning_profile_fakes.dart';
import '../support/quiz_fakes.dart';

void main() {
  late FakeLearningProfileRepository learningProfile;
  late FakeQuizRepository quizzes;
  late ProviderContainer container;

  setUp(() {
    learningProfile = FakeLearningProfileRepository()
      ..weakConcepts = [homeWeakConcept];
    quizzes = FakeQuizRepository();
    container = ProviderContainer(
      overrides: [
        userAuthProvider.overrideWith(HomeTestAuth.new),
        learningProfileRepositoryProvider.overrideWithValue(learningProfile),
        quizRepositoryProvider.overrideWithValue(quizzes),
        quizRouteArgProvider.overrideWithValue(7),
      ],
    );
  });
  tearDown(() => container.dispose());

  test('로그인한 사용자만 조회하고 닉네임 변경으로 다시 조회하지 않는다', () async {
    final auth = container.read(userAuthProvider.notifier) as HomeTestAuth;
    auth.setUser(null);
    container.listen(myWeakConceptsProvider, (_, _) {});
    expect(await container.read(myWeakConceptsProvider.future), isEmpty);
    expect(learningProfile.weakConceptsCount, 0);

    auth.setUser(homeUser);
    expect(await container.read(myWeakConceptsProvider.future), [
      homeWeakConcept,
    ]);
    auth.setUser(
      const UserEntity(id: 42, email: 'quiz@example.com', nickname: '변경된 이름'),
    );
    await container.read(myWeakConceptsProvider.future);
    expect(learningProfile.weakConceptsCount, 1);
    expect(learningProfile.cognitiveTypeScoresCount, 0);
  });

  test('계정 변경·로그아웃 시 이전 사용자의 늦은 응답을 다시 표시하지 않는다', () async {
    final requests = <Completer<Result<List<WeakConceptEntity>>>>[];
    learningProfile.onGetWeakConcepts = () {
      final pending = Completer<Result<List<WeakConceptEntity>>>();
      requests.add(pending);
      return pending.future;
    };
    container.listen(myWeakConceptsProvider, (_, _) {});
    expect(requests, hasLength(1));
    final auth = container.read(userAuthProvider.notifier) as HomeTestAuth;
    auth.setUser(
      const UserEntity(id: 99, email: 'new@example.com', nickname: '새 사용자'),
    );
    container.read(myWeakConceptsProvider);
    expect(requests, hasLength(2));
    requests.last.complete(Result.success([]));
    expect(await container.read(myWeakConceptsProvider.future), isEmpty);
    requests.first.complete(Result.success([homeWeakConcept]));
    await Future<void>.delayed(Duration.zero);
    expect(container.read(myWeakConceptsProvider).requireValue, isEmpty);
    auth.setUser(null);
    expect(await container.read(myWeakConceptsProvider.future), isEmpty);
    expect(learningProfile.weakConceptsCount, 2);
  });

  test('답안 제출 성공 후 추천을 갱신하고 저장된 결과를 다시 열 때는 재조회하지 않는다', () async {
    container.listen(myWeakConceptsProvider, (_, _) {});
    await container.read(myWeakConceptsProvider.future);
    quizzes.onSubmit = () async {
      learningProfile.weakConcepts = [];
      return Result.success(testSubmission);
    };
    container.listen(quizSubmitProvider, (_, _) {});
    final submit = container.read(quizSubmitProvider.notifier);
    await submit.submit(quiz: testQuiz, answers: testAnswers);
    expect(await container.read(myWeakConceptsProvider.future), isEmpty);
    expect(learningProfile.weakConceptsCount, 2);
    await submit.submit(quiz: testQuiz, answers: testAnswers);
    await container.read(myWeakConceptsProvider.future);
    expect(learningProfile.weakConceptsCount, 2);
  });

  test('제출 실패 시 추천을 갱신하거나 추가 요청하지 않는다', () async {
    container.listen(myWeakConceptsProvider, (_, _) {});
    await container.read(myWeakConceptsProvider.future);
    quizzes.onSubmit = () async => Result.failure(Exception('offline'));
    container.listen(quizSubmitProvider, (_, _) {});
    await container
        .read(quizSubmitProvider.notifier)
        .submit(quiz: testQuiz, answers: testAnswers);
    expect(await container.read(myWeakConceptsProvider.future), [
      homeWeakConcept,
    ]);
    expect(learningProfile.weakConceptsCount, 1);
  });
}
