import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/di/learning_profile/learning_profile.dart';
import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/app/style/app_theme.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/core/services/app_size.dart';
import 'package:iquiz/features/auth/repositories/entities/user_entity.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/cognitive_type_score_entity.dart';
import 'package:iquiz/features/learning_profile/repositories/enums/cognitive_type.enum.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_job_entity.dart';
import 'package:iquiz/presentation/pages/profile/profile_page.dart';
import 'package:iquiz/presentation/pages/profile/providers/my_cognitive_type_scores_provider.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/providers/quiz_route_arg.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/providers/quiz_submit_provider.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/quiz_play_page.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_upload/quiz_upload_page.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';

import '../support/home_fakes.dart';
import '../support/learning_profile_fakes.dart';
import '../support/quiz_fakes.dart';

CognitiveTypeScoreEntity score(
  CognitiveType type,
  double? accuracy, {
  bool enough = true,
}) => CognitiveTypeScoreEntity(
  cognitiveType: type,
  answeredCount: accuracy == null ? 0 : 100,
  correctAnswerCount: accuracy == null ? 0 : (accuracy * 100).round(),
  accuracy: accuracy,
  isEnoughData: enough && accuracy != null,
);

List<CognitiveTypeScoreEntity> designScores() => [
  score(.remember, .86),
  score(.understand, .72),
  score(.apply, .41),
  score(.analyze, .63),
  score(.evaluate, .55),
];

void main() {
  late FakeLearningProfileRepository profile;
  late FakeQuizRepository quizzes;
  late ProviderContainer container;
  late GoRouter router;
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

  setUp(() {
    profile = FakeLearningProfileRepository()
      ..cognitiveTypeScores = designScores()
      ..weakConcepts = [homeWeakConcept];
    quizzes = FakeQuizRepository()..materials = [homeMaterial()];
  });

  Future<void> start(
    WidgetTester tester, {
    bool settle = true,
    double width = 384,
    double scale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 832);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    container = ProviderContainer(
      overrides: [
        userAuthProvider.overrideWith(HomeTestAuth.new),
        learningProfileRepositoryProvider.overrideWithValue(profile),
        quizRepositoryProvider.overrideWithValue(quizzes),
      ],
    );
    (container.read(userAuthProvider.notifier) as HomeTestAuth).setUser(
      const UserEntity(id: 42, email: 'quiz@example.com', nickname: '테스트 계정'),
    );
    router = GoRouter(initialLocation: '/home', routes: $appRoutes);
    addTearDown(container.dispose);
    addTearDown(router.dispose);
    boundary = GlobalKey();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(
          key: boundary,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: router,
            builder: (context, child) {
              AppSize.init(context);
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('main_tab_profile')));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  Future<void> preview(WidgetTester tester) async {
    if (!const bool.fromEnvironment('PROFILE_PREVIEWS')) return;
    await tester.runAsync(() async {
      final render =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await render.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('/private/tmp/iquiz-profile.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets('프로필에 사용자 정보와 실제 다섯 유형 정답률을 디자인대로 표시한다', (tester) async {
    await start(tester);
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('테스트 계정'), findsOneWidget);
    expect(find.text('quiz@example.com'), findsOneWidget);
    for (final text in [
      '외우기',
      '이해하기',
      '응용하기',
      '비교하기',
      '판단하기',
      '86%',
      '72%',
      '41%',
      '63%',
      '55%',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    expect(tester.widget<Text>(find.text('41%')).style!.color, AppColor.danger);
    expect(
      tester.getSize(find.byKey(const ValueKey('profile_fill_weaknesses'))),
      const Size(352, 44),
    );
    expect(profile.cognitiveTypeScoresCount, 1);
    expect(tester.takeException(), isNull);
    await preview(tester);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('미풀이·데이터 부족·실제 0%를 구분한다', (tester) async {
    profile.cognitiveTypeScores = [
      score(.remember, null),
      score(.understand, .8, enough: false),
      score(.apply, 0),
      score(.analyze, .5),
      score(.evaluate, 1),
    ];
    await start(tester);
    expect(find.text('미풀이'), findsOneWidget);
    expect(find.text('데이터 부족'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('80%'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('조회 중에는 예시 수치를 표시하지 않고 실패 후 재시도한다', (tester) async {
    final pending = Completer<Result<List<CognitiveTypeScoreEntity>>>();
    profile.onGetCognitiveTypeScores = () => pending.future;
    await start(tester, settle: false);
    expect(find.text('86%'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(Result.failure(Exception('offline')));
    await tester.pumpAndSettle();
    expect(find.text('학습 분석을 불러오지 못했어요'), findsOneWidget);
    profile.onGetCognitiveTypeScores = null;
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    expect(find.text('86%'), findsOneWidget);
    expect(profile.cognitiveTypeScoresCount, 2);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('빈 학습 기록과 빈 약한 개념을 안내한다', (tester) async {
    profile.cognitiveTypeScores = [
      for (final type in CognitiveType.values) score(type, null),
    ];
    profile.weakConcepts = [];
    await start(tester);
    expect(find.text('미풀이'), findsNWidgets(5));
    expect(find.text('퀴즈를 풀면 나의 학습 분석이 나타나요'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('profile_fill_weaknesses')));
    await tester.pumpAndSettle();
    expect(find.text('아직 복습할 개념이 없어요.\n퀴즈를 풀면 약한 개념을 알려드려요.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('약한 개념을 선택하고 중복 요청 없이 5문제 생성 후 퀴즈를 연다', (tester) async {
    quizzes.onUpload = () async => Result.success(11);
    quizzes.onWatchGeneration = () => Stream.value(
      Result.success(
        const QuizGenerationJobEntity(jobId: 11, status: .done, quizId: 7),
      ),
    );
    await start(tester);
    await tester.tap(find.byKey(const ValueKey('profile_fill_weaknesses')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('profile_weak_concept_12')));
    await tester.pumpAndSettle();
    expect(find.byType(QuizUploadPage), findsOneWidget);
    expect(find.text('TCP 연결 과정'), findsOneWidget);
    expect(find.text('약점 문제 생성'), findsOneWidget);
    expect(find.byKey(const ValueKey('upload_count')), findsNothing);
    await tester.tap(find.text('약점 문제 5개 생성'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    expect(quizzes.weaknessGenerationRequests, [12]);
    expect(quizzes.uploadRequests, 0);
    expect(quizzes.materialGenerationRequests, isEmpty);
    await tester.tap(find.text('문제 풀기'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    expect(find.byType(QuizPlayPage), findsOneWidget);
    expect(
      GoRouterState.of(tester.element(find.byType(QuizPlayPage))).uri.path,
      '/upload/quiz/7',
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('프로필의 검색과 업로드 버튼을 연결한다', (tester) async {
    await start(tester);
    await tester.tap(find.byTooltip('자료 검색'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '없는 자료');
    await tester.pumpAndSettle();
    expect(find.text('검색 결과가 없어요.'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('학습 자료 업로드'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizUploadPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('당겨 새로고침하면 분석을 다시 불러오고 로그아웃하면 캐시를 비운다', (tester) async {
    await start(tester);
    profile.cognitiveTypeScores = [
      for (final type in CognitiveType.values) score(type, .9),
    ];
    await tester.drag(
      find.byKey(const PageStorageKey('profile_content')),
      const Offset(0, 400),
    );
    await tester.pumpAndSettle();
    expect(find.text('90%'), findsNWidgets(5));
    expect(profile.cognitiveTypeScoresCount, 2);
    await tester.tap(find.text('로그아웃'));
    await tester.pumpAndSettle();
    expect(container.read(userAuthProvider).status, AuthStatus.unauthenticated);
    expect(await container.read(myCognitiveTypeScoresProvider.future), isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('좁은 화면과 큰 글씨에서도 긴 계정 정보와 분석을 스크롤한다', (tester) async {
    await start(tester, width: 320, scale: 1.5);
    (container.read(userAuthProvider.notifier) as HomeTestAuth).setUser(
      const UserEntity(
        id: 42,
        email: 'a-very-long-email-address@example.com',
        nickname: '아주 긴 이름을 사용하는 학습자',
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('profile_fill_weaknesses')),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  test('계정 변경 중 늦게 도착한 분석을 폐기하고 채점 후 분석을 갱신한다', () async {
    final requests = <Completer<Result<List<CognitiveTypeScoreEntity>>>>[];
    profile.onGetCognitiveTypeScores = () {
      final pending = Completer<Result<List<CognitiveTypeScoreEntity>>>();
      requests.add(pending);
      return pending.future;
    };
    container = ProviderContainer(
      overrides: [
        userAuthProvider.overrideWith(HomeTestAuth.new),
        learningProfileRepositoryProvider.overrideWithValue(profile),
        quizRepositoryProvider.overrideWithValue(quizzes),
        quizRouteArgProvider.overrideWithValue(7),
      ],
    );
    addTearDown(container.dispose);
    container.listen(myCognitiveTypeScoresProvider, (_, _) {});
    final auth = container.read(userAuthProvider.notifier) as HomeTestAuth;
    auth.setUser(
      const UserEntity(id: 99, email: 'new@example.com', nickname: '다른 계정'),
    );
    container.read(myCognitiveTypeScoresProvider);
    requests.last.complete(Result.success([]));
    expect(await container.read(myCognitiveTypeScoresProvider.future), isEmpty);
    requests.first.complete(Result.success(designScores()));
    await Future<void>.delayed(Duration.zero);
    expect(container.read(myCognitiveTypeScoresProvider).requireValue, isEmpty);
    profile.onGetCognitiveTypeScores = null;
    profile.cognitiveTypeScores = designScores();
    container.listen(quizSubmitProvider, (_, _) {});
    await container
        .read(quizSubmitProvider.notifier)
        .submit(quiz: testQuiz, answers: testAnswers);
    expect(
      await container.read(myCognitiveTypeScoresProvider.future),
      hasLength(5),
    );
    expect(profile.cognitiveTypeScoresCount, 3);
  });
}
