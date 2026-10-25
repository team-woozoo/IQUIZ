import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/app/di/learning_profile/learning_profile.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/weak_concept_entity.dart';
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/app/style/app_theme.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/core/services/app_size.dart';
import 'package:iquiz/features/auth/repositories/entities/user_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/study_material_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_summary_entity.dart';
import 'package:iquiz/presentation/pages/material/material_detail_page.dart';
import 'package:iquiz/presentation/pages/profile/profile_page.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/quiz_play_page.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_result/quiz_result_page.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_upload/quiz_upload_page.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';
import 'package:iquiz/presentation/providers/quiz/quiz_generation_activity_provider.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_generation_status.enum.dart';

import '../support/home_fakes.dart';
import '../support/learning_profile_fakes.dart';
import '../support/quiz_fakes.dart';

void main() {
  late GoRouter router;
  late ProviderContainer container;
  late GlobalKey boundary;

  setUpAll(() async {
    await (FontLoader('pretendard')
          ..addFont(
            rootBundle.load('assets/fonts/pretendard/Pretendard-Regular.otf'),
          )
          ..addFont(
            rootBundle.load('assets/fonts/pretendard/Pretendard-Medium.otf'),
          )
          ..addFont(
            rootBundle.load('assets/fonts/pretendard/Pretendard-SemiBold.otf'),
          ))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  Future<void> start(
    WidgetTester tester,
    FakeQuizRepository repository, {
    bool settle = true,
    double width = 390,
    double height = 844,
    FakeLearningProfileRepository? learningProfile,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    container = ProviderContainer(
      overrides: [
        userAuthProvider.overrideWith(HomeTestAuth.new),
        quizRepositoryProvider.overrideWithValue(repository),
        learningProfileRepositoryProvider.overrideWithValue(
          learningProfile ??
              (FakeLearningProfileRepository()
                ..weakConcepts = [homeWeakConcept]),
        ),
      ],
    );
    router = GoRouter(
      initialLocation: const HomeRoute().location,
      routes: $appRoutes,
    );
    addTearDown(router.dispose);
    addTearDown(container.dispose);
    boundary = GlobalKey();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(
          key: boundary,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            theme: AppTheme.light,
            builder: (context, child) {
              AppSize.init(context);
              return child!;
            },
          ),
        ),
      ),
    );
    if (settle) await tester.pumpAndSettle();
  }

  Future<void> preview(
    WidgetTester tester, {
    String path = '/private/tmp/iquiz-home.png',
  }) async {
    if (!const bool.fromEnvironment('HOME_PREVIEWS')) return;
    await tester.runAsync(
      () => precacheImage(
        const AssetImage('assets/home/review_cover.png'),
        tester.element(find.byType(CustomScrollView)),
      ),
    );
    await tester.pumpAndSettle();
    final render =
        boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await render.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(path).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets('자료 목록을 표시하고 추가 요청 없이 스크롤한 뒤 자료 상세로 이동한다', (tester) async {
    final repository = FakeQuizRepository()
      ..materials = [
        homeMaterial(),
        homeMaterial(id: 8, title: '데이터베이스 요약'),
        homeMaterial(id: 9, title: '알고리즘 정리'),
        for (var i = 10; i < 40; i++) homeMaterial(id: i, title: '추가 자료 $i'),
      ];
    await start(tester, repository, width: 384);
    expect(find.text('TCP 연결 과정 개념이 약해요'), findsOneWidget);
    expect(find.text('해당 개념을 다시 풀어볼까요?'), findsOneWidget);
    final recommendation = find.byKey(
      const ValueKey('home_review_recommendation'),
    );
    expect(tester.getSize(recommendation).width, 352);
    expect(tester.getSize(recommendation).height, closeTo(120, 0.001));
    final cover = find.descendant(
      of: recommendation,
      matching: find.byType(Image),
    );
    expect(
      (tester.widget<Image>(cover).image as AssetImage).assetName,
      'assets/home/review_cover.png',
    );
    expect(tester.getSize(cover).width, closeTo(60, 0.001));
    expect(tester.getSize(cover).height, closeTo(80, 0.001));
    expect(find.text('최근 자료'), findsOneWidget);
    expect(find.text('네트워크'), findsNothing);
    expect(find.text('10문제 · 80% 정답'), findsNothing);
    final material = find.ancestor(
      of: find.text('운영체제 핵심 정리'),
      matching: find.byType(InkWell),
    );
    expect(tester.getSize(material).height, closeTo(76, 0.001));
    expect(find.text('추가 자료 39'), findsNothing);
    await preview(tester);

    await tester.scrollUntilVisible(
      find.text('알고리즘 정리'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('알고리즘 정리'), findsOneWidget);
    expect(find.text('10문제 · 아직 풀지 않았어요'), findsNothing);
    expect(repository.materialsCount, 1);
    await tester.scrollUntilVisible(
      find.text('운영체제 핵심 정리'),
      -250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('운영체제 핵심 정리'));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialDetailPage), findsOneWidget);
    expect(
      GoRouterState.of(tester.element(find.byType(MaterialDetailPage)))
          .uri
          .path,
      const MaterialDetailRoute(1).location,
    );
    expect(repository.materialsCount, 1);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('풀이 기록이 없으면 해당 자료의 최신 퀴즈로 바로 이동한다', (tester) async {
    final repository = FakeQuizRepository()
      ..materials = [homeMaterial(answeredCount: 0)]
      ..quizzes = [
        homeQuiz(quizId: 99, createdAt: DateTime.utc(2026, 10, 18)),
        homeQuiz(createdAt: DateTime.utc(2026, 10, 21)),
        homeQuiz(quizId: 100, materialId: 8),
      ];
    await start(tester, repository);
    await tester.tap(find.text('운영체제 핵심 정리'));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialDetailPage), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    final page = tester.widget<QuizPlayPage>(find.byType(QuizPlayPage));
    expect(page.quizId, 7);
    expect(page.title, '운영체제 핵심 정리');
    expect(repository.quizMaterialFilters, [1]);
    expect(repository.materialDetailRequests, isEmpty);
    expect(repository.conceptRequests, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('검색에서도 풀이 기록이 없으면 선택한 자료의 문제로 바로 이동한다', (tester) async {
    final repository = FakeQuizRepository()
      ..materials = [
        homeMaterial(),
        homeMaterial(id: 8, title: '처음 풀 자료', answeredCount: 0),
      ]
      ..quizzes = [homeQuiz(materialId: 8)];
    await start(tester, repository);
    await tester.tap(find.byTooltip('자료 검색'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '처음');
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('처음 풀 자료'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    final page = tester.widget<QuizPlayPage>(find.byType(QuizPlayPage));
    expect(page.quizId, 7);
    expect(page.title, '처음 풀 자료');
    expect(repository.quizMaterialFilters, [8]);
    expect(repository.materialDetailRequests, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('문제 조회 중 여러 번 눌러도 요청과 화면 이동은 한 번만 수행한다', (tester) async {
    final pending = Completer<Result<List<QuizSummaryEntity>>>();
    final repository = FakeQuizRepository()
      ..materials = [homeMaterial(answeredCount: 0)]
      ..onGetMyQuizzes = () => pending.future;
    await start(tester, repository);
    await tester.tap(find.text('운영체제 핵심 정리'));
    await tester.tap(find.text('운영체제 핵심 정리'));
    await tester.pump();
    expect(repository.myQuizzesCount, 1);
    pending.complete(Result.success([homeQuiz()]));
    await tester.pumpAndSettle();
    expect(find.byType(QuizPlayPage), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, HomeRoute.path);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('늦은 문제 응답 이후 홈으로 돌아와도 다른 자료를 선택할 수 있다', (tester) async {
    final pending = Completer<Result<List<QuizSummaryEntity>>>();
    final repository = FakeQuizRepository()
      ..materials = [
        homeMaterial(answeredCount: 0),
        homeMaterial(id: 8, title: '다른 자료'),
      ]
      ..onGetMyQuizzes = () => pending.future;
    await start(tester, repository);
    await tester.tap(find.text('운영체제 핵심 정리'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    pending.complete(Result.success([homeQuiz()]));
    await tester.pumpAndSettle();
    expect(find.byType(QuizPlayPage), findsOneWidget);
    const HomeRoute().go(tester.element(find.byType(QuizPlayPage)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다른 자료'));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialDetailPage), findsOneWidget);
    expect(repository.materialDetailRequests, [8]);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('풀이 결과의 홈 버튼으로 복귀한 뒤 같은 자료를 다시 열 수 있다', (tester) async {
    final repository = FakeQuizRepository()
      ..materials = [homeMaterial(answeredCount: 0)]
      ..quizzes = [homeQuiz()];
    repository.onSubmit = () async {
      repository.materials = [homeMaterial()];
      return Result.success(testSubmission);
    };
    await start(tester, repository);
    for (final text in ['운영체제 핵심 정리', '보기 A', '다음 문제', '보기 D', '결과 보기']) {
      await tester.tap(find.text(text));
      await tester.pumpAndSettle();
    }
    expect(find.byType(QuizResultPage), findsOneWidget);
    await tester.tap(find.text('홈'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('운영체제 핵심 정리'));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialDetailPage), findsOneWidget);
    expect(repository.submitCount, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('검색으로 문제를 연 뒤 홈으로 복귀해도 다시 검색할 수 있다', (tester) async {
    final repository = FakeQuizRepository()
      ..materials = [homeMaterial(answeredCount: 0)]
      ..quizzes = [homeQuiz()];
    await start(tester, repository);
    await tester.tap(find.byTooltip('자료 검색'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('운영체제 핵심 정리'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(QuizPlayPage), findsOneWidget);
    const HomeRoute().go(tester.element(find.byType(QuizPlayPage)));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('자료 검색'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('운영체제 핵심 정리'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(QuizPlayPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('생성된 문제가 없으면 홈에서 안내하고 생성 후 다시 누르면 문제를 연다', (tester) async {
    final repository = FakeQuizRepository()
      ..materials = [homeMaterial(answeredCount: 0, generating: true)];
    await start(tester, repository);
    await tester.tap(find.text('운영체제 핵심 정리'));
    await tester.pumpAndSettle();
    expect(find.text('문제를 만들고 있어요. 잠시 후 다시 눌러 주세요.'), findsOneWidget);
    expect(find.byType(MaterialDetailPage), findsNothing);
    expect(find.byType(QuizPlayPage), findsNothing);
    repository.quizzes = [homeQuiz()];
    await tester.tap(find.text('운영체제 핵심 정리'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizPlayPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('문제 조회 실패 시 홈에서 안내하고 다시 누르면 재시도한다', (tester) async {
    final repository = FakeQuizRepository()
      ..materials = [homeMaterial(answeredCount: 0)]
      ..onGetMyQuizzes = () async => Result.failure(Exception('offline'));
    await start(tester, repository);
    await tester.tap(find.text('운영체제 핵심 정리'));
    await tester.pumpAndSettle();
    expect(find.text('문제를 불러오지 못했어요. 다시 눌러 주세요.'), findsOneWidget);
    expect(find.byType(QuizPlayPage), findsNothing);
    repository.onGetMyQuizzes = null;
    repository.quizzes = [homeQuiz()];
    await tester.tap(find.text('운영체제 핵심 정리'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizPlayPage), findsOneWidget);
    expect(repository.myQuizzesCount, 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('한 문항만 제출했어도 자료 상세로 이동한다', (tester) async {
    final repository = FakeQuizRepository()
      ..materials = [homeMaterial(answeredCount: 1)];
    await start(tester, repository);
    await tester.tap(find.text('운영체제 핵심 정리'));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialDetailPage), findsOneWidget);
    expect(find.byType(QuizPlayPage), findsNothing);
    expect(repository.materialDetailRequests, [1]);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('빈 목록을 안내하고 아래로 당겨 새로고침하면 새 자료를 표시한다', (tester) async {
    final repository = FakeQuizRepository();
    await start(tester, repository);
    expect(find.text('아직 올린 자료가 없어요'), findsOneWidget);
    repository.materials = [homeMaterial()];
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(find.text('운영체제 핵심 정리'), findsOneWidget);
    expect(repository.materialsCount, 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('로딩·오류 상태를 표시하고 다시 시도하면 정상 목록으로 복구한다', (tester) async {
    final pending = Completer<Result<List<StudyMaterialEntity>>>();
    final repository = FakeQuizRepository()
      ..onGetMyMaterials = () => pending.future;
    await start(tester, repository, settle: false);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(Result.failure(Exception('offline')));
    await tester.pumpAndSettle();
    expect(find.text('자료 목록을 불러오지 못했어요'), findsOneWidget);
    expect(find.byTooltip('학습 자료 업로드'), findsOneWidget);
    expect(repository.materialsCount, 1);
    repository.onGetMyMaterials = null;
    repository.materials = [homeMaterial()];
    await tester.ensureVisible(find.text('다시 시도'));
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    expect(find.text('운영체제 핵심 정리'), findsOneWidget);
    expect(repository.materialsCount, 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('새로고침 실패를 화면에 표시하고 비동기 예외를 밖으로 유출하지 않는다', (tester) async {
    final repository = FakeQuizRepository()..materials = [homeMaterial()];
    await start(tester, repository);
    repository.onGetMyMaterials = () async =>
        Result.failure(Exception('offline'));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(find.text('자료 목록을 불러오지 못했어요'), findsOneWidget);
    expect(repository.materialsCount, 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('검색어를 필터링하고 초기화한 뒤 결과를 선택하면 해당 자료 상세로 이동한다', (tester) async {
    final repository = FakeQuizRepository()
      ..materials = [homeMaterial(), homeMaterial(id: 8, title: '데이터베이스 요약')];
    await start(tester, repository);
    await tester.tap(find.byTooltip('자료 검색'));
    await tester.pumpAndSettle();
    final sheet = find.byType(BottomSheet);
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, ' 데이터베이스 ');
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: sheet, matching: find.text('운영체제 핵심 정리')),
      findsNothing,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('데이터베이스 요약')),
      findsOneWidget,
    );
    await tester.enterText(searchField, '없는 제목');
    await tester.pumpAndSettle();
    expect(find.text('검색 결과가 없어요.'), findsOneWidget);
    await tester.tap(find.byTooltip('검색어 지우기'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: sheet, matching: find.text('운영체제 핵심 정리')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(MaterialDetailPage), findsOneWidget);
    expect(
      GoRouterState.of(tester.element(find.byType(MaterialDetailPage)))
          .uri
          .path,
      const MaterialDetailRoute(1).location,
    );
    expect(repository.materialsCount, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('추가 버튼을 누르면 기존 업로드 화면으로 이동한다', (tester) async {
    await start(tester, FakeQuizRepository());
    await tester.tap(find.byTooltip('학습 자료 업로드'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizUploadPage), findsOneWidget);
    expect(
      GoRouterState.of(tester.element(find.byType(QuizUploadPage))).uri.path,
      UploadRoute.path,
    );
    expect(find.text('문제 생성'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('좁은 화면에서도 긴 닉네임으로 프로필에 진입한다', (tester) async {
    final repository = FakeQuizRepository()
      ..materials = [
        homeMaterial(title: '아주 긴 학습 자료 제목을 가진 운영체제와 데이터베이스 강의 정리'),
      ];
    await start(tester, repository, width: 320);
    (container.read(userAuthProvider.notifier) as HomeTestAuth).setUser(
      const UserEntity(
        id: 42,
        email: 'quiz@example.com',
        nickname: '긴닉네임을가진학습자',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('프로필'));
    await tester.pumpAndSettle();
    expect(find.text('긴닉네임을가진학습자'), findsOneWidget);
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(
      tester
          .widget<InkWell>(find.byKey(const ValueKey('main_tab_profile')))
          .onTap,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('서버의 첫 취약 개념을 표시하고 카드를 눌러도 이동하거나 요청하지 않는다', (tester) async {
    final learningProfile = FakeLearningProfileRepository()
      ..weakConcepts = [
        homeWeakConcept,
        const WeakConceptEntity(
          conceptId: 13,
          conceptName: '정규화',
          materialId: 4,
          materialTitle: '데이터베이스',
          answeredCount: 10,
          correctAnswerCount: 5,
          accuracy: 0.5,
        ),
      ];
    await start(tester, FakeQuizRepository(), learningProfile: learningProfile);
    expect(find.text('TCP 연결 과정 개념이 약해요'), findsOneWidget);
    expect(find.text('정규화 개념이 약해요'), findsNothing);
    final location = router.routeInformationProvider.value.uri;
    await tester.tap(find.byKey(const ValueKey('home_review_recommendation')));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri, location);
    expect(learningProfile.weakConceptsCount, 1);
    expect(learningProfile.cognitiveTypeScoresCount, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('추천 조회 중에는 예시 개념을 표시하지 않고 응답이 오면 실제 개념으로 바꾼다', (tester) async {
    final pending = Completer<Result<List<WeakConceptEntity>>>();
    final learningProfile = FakeLearningProfileRepository()
      ..onGetWeakConcepts = () => pending.future;
    await start(
      tester,
      FakeQuizRepository(),
      settle: false,
      learningProfile: learningProfile,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == '복습할 개념을 불러오는 중이에요',
      ),
      findsOneWidget,
    );
    expect(find.text('TCP 연결 과정 개념이 약해요'), findsNothing);
    pending.complete(Result.success([homeWeakConcept]));
    await tester.pumpAndSettle();
    expect(find.text('TCP 연결 과정 개념이 약해요'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('취약 개념이 없으면 중립적인 안내를 표시하고 카드 클릭을 비활성화한다', (tester) async {
    await start(
      tester,
      FakeQuizRepository(),
      width: 384,
      learningProfile: FakeLearningProfileRepository(),
    );
    expect(find.text('아직 분석할 개념이 없어요'), findsOneWidget);
    expect(find.text('퀴즈를 풀면 복습할 개념을 알려드려요'), findsOneWidget);
    final recommendation = find.byKey(
      const ValueKey('home_review_recommendation'),
    );
    expect(tester.getSize(recommendation), const Size(352, 86));
    expect(
      find.descendant(of: recommendation, matching: find.byType(Image)),
      findsNothing,
    );
    final ink = find.descendant(
      of: find.byKey(const ValueKey('home_review_recommendation')),
      matching: find.byType(InkWell),
    );
    expect(tester.widget<InkWell>(ink).onTap, isNull);
    await preview(tester, path: '/private/tmp/iquiz-home-review-empty.png');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('추천 조회 실패는 목록과 별도로 표시하고 당겨 새로고침하면 함께 갱신한다', (tester) async {
    final quizzes = FakeQuizRepository()..materials = [homeMaterial()];
    final learningProfile = FakeLearningProfileRepository()
      ..onGetWeakConcepts = () async => Result.failure(Exception('offline'));
    await start(tester, quizzes, learningProfile: learningProfile);
    expect(find.text('복습할 개념을 불러오지 못했어요'), findsOneWidget);
    expect(find.text('운영체제 핵심 정리'), findsOneWidget);
    learningProfile.onGetWeakConcepts = null;
    learningProfile.weakConcepts = [homeWeakConcept];
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(find.text('TCP 연결 과정 개념이 약해요'), findsOneWidget);
    expect(learningProfile.weakConceptsCount, 2);
    expect(quizzes.materialsCount, 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('좁은 화면에서도 긴 개념명을 자르거나 넘치지 않고 표시한다', (tester) async {
    const name = '데이터베이스 트랜잭션의 동시성 제어와 직렬 가능성 보장';
    final learningProfile = FakeLearningProfileRepository()
      ..weakConcepts = [
        const WeakConceptEntity(
          conceptId: 12,
          conceptName: name,
          materialId: 3,
          materialTitle: '데이터베이스',
          answeredCount: 10,
          correctAnswerCount: 3,
          accuracy: 0.3,
        ),
      ];
    await start(
      tester,
      FakeQuizRepository(),
      width: 320,
      learningProfile: learningProfile,
    );
    expect(find.text('$name 개념이 약해요'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('변경 디자인의 PDF 목록과 자료명·생성 중 상태를 표시한다', (tester) async {
    final quizzes = FakeQuizRepository()
      ..materials = [
        homeMaterial(title: '운영체제 6주차'),
        homeMaterial(id: 8, title: '컴퓨터 네트워크 4주차'),
      ];
    final profile = FakeLearningProfileRepository()
      ..weakConcepts = [
        const WeakConceptEntity(
          conceptId: 12,
          conceptName: 'TCP 연결 과정',
          materialId: 3,
          materialTitle: '컴퓨터 네트워크 4주차',
          answeredCount: 10,
          correctAnswerCount: 3,
          accuracy: 0.3,
        ),
      ];
    await start(
      tester,
      quizzes,
      width: 384,
      height: 832,
      learningProfile: profile,
    );
    final activity = container.read(quizGenerationActivityProvider.notifier);
    final id = activity.start(title: '데이터베이스 정규화', release: () {});
    activity.update(id, QuizGenerationStatus.processing);
    await tester.pumpAndSettle();
    expect(find.text('컴퓨터 네트워크 4주차'), findsOneWidget);
    expect(find.text('문제 만드는 중...'), findsOneWidget);
    final generatingRow = find.ancestor(
      of: find.text('문제 만드는 중...'),
      matching: find.byType(InkWell),
    );
    expect(tester.widget<InkWell>(generatingRow).onTap, isNull);
    expect(tester.getSize(generatingRow).height, closeTo(76, 0.001));
    expect(find.text('아직 올린 자료가 없어요'), findsNothing);
    await preview(tester, path: '/private/tmp/iquiz-home-redesign.png');
    activity.finish(id);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('완료된 퀴즈가 없어도 생성 중 자료가 있으면 빈 목록 안내를 숨긴다', (tester) async {
    await start(tester, FakeQuizRepository());
    final activity = container.read(quizGenerationActivityProvider.notifier);
    final id = activity.start(title: '새 학습 자료', release: () {});
    await tester.pumpAndSettle();
    expect(find.text('새 학습 자료'), findsOneWidget);
    expect(find.text('자료 업로드 중...'), findsOneWidget);
    expect(find.text('아직 올린 자료가 없어요'), findsNothing);
    activity.finish(id);
    await tester.pumpAndSettle();
    expect(find.text('아직 올린 자료가 없어요'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
