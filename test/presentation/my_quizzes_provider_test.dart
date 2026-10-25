import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/auth/repositories/entities/user_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_job_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_options_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_last_submission_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_summary_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_difficulty.enum.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_format.enum.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_generation_status.enum.dart';
import 'package:iquiz/presentation/pages/home/providers/my_quizzes_provider.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/providers/quiz_route_arg.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/providers/quiz_submit_provider.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_upload/providers/quiz_upload_process.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';

import '../support/home_fakes.dart';
import '../support/quiz_fakes.dart';

void main() {
  late FakeQuizRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeQuizRepository();
    container = ProviderContainer(
      overrides: [
        quizRepositoryProvider.overrideWithValue(repository),
        userAuthProvider.overrideWith(HomeTestAuth.new),
        quizRouteArgProvider.overrideWithValue(7),
      ],
    );
  });
  tearDown(() => container.dispose());

  test('비로그인 상태에서는 조회하지 않고 로그인하면 해당 사용자의 목록을 조회한다', () async {
    final auth = container.read(userAuthProvider.notifier) as HomeTestAuth;
    auth.setUser(null);
    container.listen(myQuizzesProvider, (_, _) {});
    expect(await container.read(myQuizzesProvider.future), isEmpty);
    expect(repository.myQuizzesCount, 0);
    repository.quizzes = [homeQuiz()];
    auth.setUser(homeUser);
    expect(await container.read(myQuizzesProvider.future), hasLength(1));
    expect(repository.myQuizzesCount, 1);
  });

  test('계정 변경 전 시작한 응답이 늦게 도착해도 새 계정 목록을 덮어쓰지 않는다', () async {
    final requests = <Completer<Result<List<QuizSummaryEntity>>>>[];
    repository.onGetMyQuizzes = () {
      final pending = Completer<Result<List<QuizSummaryEntity>>>();
      requests.add(pending);
      return pending.future;
    };
    container.listen(myQuizzesProvider, (_, _) {});
    expect(requests, hasLength(1));
    (container.read(userAuthProvider.notifier) as HomeTestAuth).setUser(
      const UserEntity(id: 99, email: 'new@example.com', nickname: '다른 유저'),
    );
    container.read(myQuizzesProvider);
    expect(requests, hasLength(2));
    requests.last.complete(
      Result.success([homeQuiz(quizId: 99, title: '새 계정 퀴즈')]),
    );
    expect((await container.read(myQuizzesProvider.future)).single.quizId, 99);
    requests.first.complete(Result.success([homeQuiz(title: '이전 계정 퀴즈')]));
    await Future<void>.delayed(Duration.zero);
    expect(container.read(myQuizzesProvider).requireValue.single.quizId, 99);
    (container.read(userAuthProvider.notifier) as HomeTestAuth).setUser(null);
    expect(await container.read(myQuizzesProvider.future), isEmpty);
  });

  test('답안 제출 성공 시 목록을 갱신하고 같은 결과를 다시 열 때는 추가 조회하지 않는다', () async {
    repository.quizzes = [homeQuiz()];
    container.listen(myQuizzesProvider, (_, _) {});
    await container.read(myQuizzesProvider.future);
    repository.onSubmit = () async {
      repository.quizzes = [
        homeQuiz(
          submissionCount: 1,
          lastSubmission: QuizLastSubmissionEntity(
            correctCount: 1,
            submittedAt: DateTime.utc(2026, 10, 19),
          ),
        ),
      ];
      return Result.success(testSubmission);
    };
    container.listen(quizSubmitProvider, (_, _) {});
    final notifier = container.read(quizSubmitProvider.notifier);
    await notifier.submit(quiz: testQuiz, answers: testAnswers);
    final quizzes = await container.read(myQuizzesProvider.future);
    expect(quizzes.single.submissionCount, 1);
    expect(repository.myQuizzesCount, 2);
    await notifier.submit(quiz: testQuiz, answers: testAnswers);
    await container.read(myQuizzesProvider.future);
    expect(repository.myQuizzesCount, 2);
  });

  test('퀴즈 생성이 완료되면 홈 목록에 새 퀴즈를 반영한다', () async {
    container.listen(myQuizzesProvider, (_, _) {});
    await container.read(myQuizzesProvider.future);
    repository.onUpload = () async => Result.success(11);
    repository.onWatchGeneration = () async* {
      repository.quizzes = [homeQuiz(quizId: 8)];
      yield Result.success(
        const QuizGenerationJobEntity(
          jobId: 11,
          status: QuizGenerationStatus.done,
          quizId: 8,
        ),
      );
    };
    final completed = Completer<void>();
    container.listen(
      quizUploadProcessProvider(
        fileBytes: [1, 2, 3],
        fileName: '자료.pdf',
        options: const QuizGenerationOptionsEntity(
          format: QuizFormat.ox,
          difficulty: QuizDifficulty.normal,
        ),
      ),
      (_, value) {
        if (value.asData?.value.status == QuizGenerationStatus.done &&
            !completed.isCompleted) {
          completed.complete();
        }
      },
    );
    await completed.future;
    expect((await container.read(myQuizzesProvider.future)).single.quizId, 8);
    expect(repository.myQuizzesCount, 2);
  });
}
