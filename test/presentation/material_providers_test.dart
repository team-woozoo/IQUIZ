import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/auth/repositories/entities/user_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/study_material_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_job_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_options_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_generation_status.enum.dart';
import 'package:iquiz/presentation/providers/material/material_providers.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';
import 'package:iquiz/presentation/pages/home/providers/my_quizzes_provider.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/providers/quiz_route_arg.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/providers/quiz_submit_provider.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_upload/providers/quiz_upload_process.dart';

import '../support/home_fakes.dart';
import '../support/material_fakes.dart';
import '../support/quiz_fakes.dart';

void main() {
  late FakeQuizRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeQuizRepository()
      ..materials = [testMaterial(), testMaterial(id: 2)]
      ..quizzes = [homeQuiz(), homeQuiz(quizId: 8, materialId: 2)];
    container = ProviderContainer(
      overrides: [
        quizRepositoryProvider.overrideWithValue(repository),
        userAuthProvider.overrideWith(HomeTestAuth.new),
        quizRouteArgProvider.overrideWithValue(7),
      ],
    );
  });
  tearDown(() => container.dispose());

  test('미로그인 시 자료·상세·개념·기록을 요청하지 않고 로그인 후 조회한다', () async {
    final auth = container.read(userAuthProvider.notifier) as HomeTestAuth;
    auth.setUser(null);
    container.listen(myMaterialsProvider, (_, _) {});
    container.listen(myMaterialProvider(materialId: 1), (_, _) {});
    container.listen(myMaterialConceptsProvider(materialId: 1), (_, _) {});
    container.listen(materialQuizzesProvider(materialId: 1), (_, _) {});
    expect(await container.read(myMaterialsProvider.future), isEmpty);
    expect(
      await container.read(myMaterialProvider(materialId: 1).future),
      isNull,
    );
    expect(
      await container.read(myMaterialConceptsProvider(materialId: 1).future),
      isEmpty,
    );
    expect(
      await container.read(materialQuizzesProvider(materialId: 1).future),
      isEmpty,
    );
    expect(repository.materialsCount, 0);
    expect(repository.materialDetailRequests, isEmpty);
    expect(repository.conceptRequests, isEmpty);
    expect(repository.quizMaterialFilters, isEmpty);
    auth.setUser(homeUser);
    expect(await container.read(myMaterialsProvider.future), hasLength(2));
    expect(
      (await container.read(myMaterialProvider(materialId: 1).future))
          ?.materialId,
      1,
    );
    expect(
      await container.read(myMaterialConceptsProvider(materialId: 1).future),
      isEmpty,
    );
    expect(
      (await container.read(materialQuizzesProvider(materialId: 1).future))
          .single
          .quizId,
      7,
    );
  });

  test('자료별 퀴즈 캐시는 전체 목록 및 다른 자료의 캐시와 분리된다', () async {
    container.listen(myQuizzesProvider, (_, _) {});
    container.listen(materialQuizzesProvider(materialId: 1), (_, _) {});
    container.listen(materialQuizzesProvider(materialId: 2), (_, _) {});
    expect(await container.read(myQuizzesProvider.future), hasLength(2));
    expect(
      (await container.read(materialQuizzesProvider(materialId: 1).future))
          .single
          .quizId,
      7,
    );
    expect(
      (await container.read(materialQuizzesProvider(materialId: 2).future))
          .single
          .quizId,
      8,
    );
    expect(repository.quizMaterialFilters, [null, 1, 2]);
    await container.read(materialQuizzesProvider(materialId: 1).future);
    expect(repository.quizMaterialFilters, hasLength(3));
  });

  test('계정 변경 후 이전 자료 응답이 늦게 와도 새 계정을 덮어쓰지 않는다', () async {
    final requests = <Completer<Result<List<StudyMaterialEntity>>>>[];
    repository.onGetMyMaterials = () {
      final request = Completer<Result<List<StudyMaterialEntity>>>();
      requests.add(request);
      return request.future;
    };
    container.listen(myMaterialsProvider, (_, _) {});
    final auth = container.read(userAuthProvider.notifier) as HomeTestAuth;
    auth.setUser(
      const UserEntity(id: 99, email: 'new@example.com', nickname: '새 계정'),
    );
    container.read(myMaterialsProvider);
    requests.last.complete(Result.success([testMaterial(id: 99)]));
    expect(
      (await container.read(myMaterialsProvider.future)).single.materialId,
      99,
    );
    requests.first.complete(Result.success([testMaterial()]));
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(myMaterialsProvider).requireValue.single.materialId,
      99,
    );
    auth.setUser(null);
    expect(await container.read(myMaterialsProvider.future), isEmpty);
  });

  test('제출 성공 시 자료 목록과 해당 자료의 상세·개념·기록을 갱신한다', () async {
    container.listen(myMaterialsProvider, (_, _) {});
    for (final id in [1, 2]) {
      container.listen(myMaterialProvider(materialId: id), (_, _) {});
      container.listen(myMaterialConceptsProvider(materialId: id), (_, _) {});
      container.listen(materialQuizzesProvider(materialId: id), (_, _) {});
      await container.read(myMaterialProvider(materialId: id).future);
      await container.read(myMaterialConceptsProvider(materialId: id).future);
      await container.read(materialQuizzesProvider(materialId: id).future);
    }
    await container.read(myMaterialsProvider.future);
    repository.materials = [testMaterial(correctCount: 1), testMaterial(id: 2)];
    container.listen(quizSubmitProvider, (_, _) {});
    await container
        .read(quizSubmitProvider.notifier)
        .submit(quiz: testQuiz, answers: testAnswers);
    await container.read(myMaterialsProvider.future);
    final detail = await container.read(
      myMaterialProvider(materialId: 1).future,
    );
    await container.read(myMaterialConceptsProvider(materialId: 1).future);
    await container.read(materialQuizzesProvider(materialId: 1).future);
    expect(detail?.correctCount, 1);
    expect(repository.materialsCount, 2);
    expect(
      repository.materialDetailRequests.where((id) => id == 1),
      hasLength(2),
    );
    expect(
      repository.materialDetailRequests.where((id) => id == 2),
      hasLength(1),
    );
    expect(repository.conceptRequests.where((id) => id == 1), hasLength(2));
    expect(repository.conceptRequests.where((id) => id == 2), hasLength(1));
    expect(repository.quizMaterialFilters.where((id) => id == 1), hasLength(2));
    expect(repository.quizMaterialFilters.where((id) => id == 2), hasLength(1));
  });

  for (final terminal in [
    QuizGenerationStatus.done,
    QuizGenerationStatus.failed,
  ]) {
    test('생성 접수 및 ${terminal.name} 시 자료 상태를 갱신한다', () async {
      container.listen(myMaterialsProvider, (_, _) {});
      await container.read(myMaterialsProvider.future);
      final events = StreamController<Result<QuizGenerationJobEntity>>();
      addTearDown(events.close);
      repository.onUpload = () async => Result.success(11);
      repository.onWatchGeneration = () => events.stream;
      final pending = Completer<void>();
      final finished = Completer<void>();
      container.listen(
        quizUploadProcessProvider(
          fileBytes: [1, 2, 3],
          fileName: '자료.pdf',
          options: const QuizGenerationOptionsEntity(
            format: .ox,
            difficulty: .normal,
          ),
        ),
        (_, state) {
          final status = state.asData?.value.status;
          if (status == QuizGenerationStatus.pending && !pending.isCompleted) {
            pending.complete();
          }
          if (status == terminal && !finished.isCompleted) finished.complete();
        },
      );
      await pending.future;
      await container.read(myMaterialsProvider.future);
      expect(repository.materialsCount, 2);
      events.add(
        Result.success(
          QuizGenerationJobEntity(
            jobId: 11,
            status: terminal,
            quizId: terminal == QuizGenerationStatus.done ? 8 : null,
            error: terminal == QuizGenerationStatus.failed
                ? Exception('생성 실패')
                : null,
          ),
        ),
      );
      await finished.future;
      await container.read(myMaterialsProvider.future);
      expect(repository.materialsCount, 3);
    });
  }
}
