import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_job_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_options_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_generation_status.enum.dart';
import 'package:iquiz/presentation/pages/home/providers/my_quizzes_provider.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_upload/providers/quiz_generation_state.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_upload/providers/quiz_upload_process.dart';
import 'package:iquiz/presentation/providers/quiz/quiz_generation_activity_provider.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';
import 'package:iquiz/presentation/providers/material/material_providers.dart';

import '../support/home_fakes.dart';
import '../support/quiz_fakes.dart';

void main() {
  late ProviderContainer container;
  late FakeQuizRepository repository;
  late StreamController<Result<QuizGenerationJobEntity>> jobs;

  setUp(() {
    jobs = StreamController<Result<QuizGenerationJobEntity>>.broadcast();
    repository = FakeQuizRepository();
    repository.onUpload = () async => Result.success(11);
    repository.onWatchGeneration = () => jobs.stream;
    container = ProviderContainer(
      overrides: [
        userAuthProvider.overrideWith(HomeTestAuth.new),
        quizRepositoryProvider.overrideWithValue(repository),
      ],
    );
    container.listen(quizGenerationActivityProvider, (_, _) {});
  });
  tearDown(() async {
    container.dispose();
    await jobs.close();
  });

  ProviderSubscription<AsyncValue<QuizGenerationState>> start() =>
      container.listen(
        quizUploadProcessProvider(
          fileBytes: [1, 2, 3],
          fileName: '데이터베이스 정규화.pdf',
          options: const QuizGenerationOptionsEntity(
            format: .multipleChoice,
            difficulty: .normal,
          ),
        ),
        (_, _) {},
      );

  test('업로드 화면을 나가도 작업을 유지하고 완료 시 목록을 갱신한다', () async {
    container.listen(myQuizzesProvider, (_, _) {});
    await container.read(myQuizzesProvider.future);
    final page = start();
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(quizGenerationActivityProvider).single.title,
      '데이터베이스 정규화',
    );
    page.close();
    await container.pump();
    expect(jobs.hasListener, isTrue);
    jobs.add(
      Result.success(
        const QuizGenerationJobEntity(jobId: 11, status: .processing),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(quizGenerationActivityProvider).single.status,
      QuizGenerationStatus.processing,
    );
    repository.quizzes = [homeQuiz()];
    jobs.add(
      Result.success(
        const QuizGenerationJobEntity(jobId: 11, status: .done, quizId: 7),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(container.read(quizGenerationActivityProvider), isEmpty);
    expect(await container.read(myQuizzesProvider.future), hasLength(1));
    expect(repository.myQuizzesCount, 2);
    expect(jobs.hasListener, isFalse);
  });

  test('계정이 종료되면 이전 작업 표시와 백그라운드 구독을 해제한다', () async {
    final page = start();
    await Future<void>.delayed(Duration.zero);
    page.close();
    await container.pump();
    expect(jobs.hasListener, isTrue);
    (container.read(userAuthProvider.notifier) as HomeTestAuth).setUser(null);
    await container.pump();
    await Future<void>.delayed(Duration.zero);
    expect(container.read(quizGenerationActivityProvider), isEmpty);
    expect(jobs.hasListener, isFalse);
  });

  test('기존 자료 생성도 화면 종료 후 유지하고 해당 자료의 기록만 갱신한다', () async {
    for (final id in [1, 2]) {
      container.listen(materialQuizzesProvider(materialId: id), (_, _) {});
      await container.read(materialQuizzesProvider(materialId: id).future);
    }
    final page = container.listen(
      quizUploadProcessProvider(
        materialId: 1,
        title: '현재 자료',
        options: const QuizGenerationOptionsEntity(
          format: .ox,
          difficulty: .normal,
        ),
      ),
      (_, _) {},
    );
    await Future<void>.delayed(Duration.zero);
    expect(repository.materialGenerationRequests, [1]);
    expect(repository.uploadRequests, 0);
    expect(
      container.read(quizGenerationActivityProvider).single.title,
      '현재 자료',
    );
    page.close();
    await container.pump();
    expect(jobs.hasListener, isTrue);
    repository.quizzes = [homeQuiz(), homeQuiz(quizId: 8, materialId: 2)];
    jobs.add(
      Result.success(
        const QuizGenerationJobEntity(jobId: 11, status: .done, quizId: 7),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(
      (await container.read(materialQuizzesProvider(materialId: 1).future))
          .single
          .quizId,
      7,
    );
    expect(repository.quizMaterialFilters.where((id) => id == 1), hasLength(3));
    expect(repository.quizMaterialFilters.where((id) => id == 2), hasLength(1));
    expect(container.read(quizGenerationActivityProvider), isEmpty);
    expect(jobs.hasListener, isFalse);
  });

  test('업로드가 실패하면 생성 중 표시를 남기지 않는다', () async {
    repository.onUpload = () async => Result.failure(Exception('offline'));
    final page = start();
    await Future<void>.delayed(Duration.zero);
    expect(page.read().hasError, isTrue);
    expect(container.read(quizGenerationActivityProvider), isEmpty);
    expect(jobs.hasListener, isFalse);
    page.close();
  });

  test('생성이 실패해도 생성 중 표시와 구독을 해제한다', () async {
    final page = start();
    await Future<void>.delayed(Duration.zero);
    jobs.add(
      Result.success(const QuizGenerationJobEntity(jobId: 11, status: .failed)),
    );
    await Future<void>.delayed(Duration.zero);
    expect(page.read().requireValue.status, QuizGenerationStatus.failed);
    expect(container.read(quizGenerationActivityProvider), isEmpty);
    expect(jobs.hasListener, isFalse);
    page.close();
  });
}
