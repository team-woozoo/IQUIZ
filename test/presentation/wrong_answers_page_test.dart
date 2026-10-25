import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/app/di/learning_profile/learning_profile.dart';
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/app/style/app_theme.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/core/services/app_size.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_question_result_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_submission_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/wrong_answer_entity.dart';
import 'package:iquiz/presentation/pages/home/providers/my_weak_concepts_provider.dart';
import 'package:iquiz/presentation/pages/main/main_page.dart';
import 'package:iquiz/presentation/pages/main/providers/main_bottom_navigation.dart';
import 'package:iquiz/presentation/pages/profile/profile_page.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_result/providers/quiz_result_route_arg.dart';
import 'package:iquiz/presentation/pages/wrong_answers/providers/my_wrong_answers_provider.dart';
import 'package:iquiz/presentation/providers/material/material_providers.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';

import '../support/home_fakes.dart';
import '../support/learning_profile_fakes.dart';
import '../support/quiz_fakes.dart';

void main() {
  late _ReviewRepository repository;
  late ProviderContainer container;
  late GoRouter router;
  late GlobalKey boundary;
  var weakLoads = 0;

  setUpAll(() async {
    await (FontLoader('pretendard')..addFont(
          rootBundle.load('assets/fonts/pretendard/Pretendard-Regular.otf'),
        ))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  setUp(() {
    weakLoads = 0;
    repository = _ReviewRepository()
      ..wrongAnswers = [_item(), _item(id: 102), _item(id: 103)]
      ..materials = [homeMaterial(title: '컴퓨터네트워크')];
  });

  Future<void> start(
    WidgetTester tester, {
    String? location,
    double width = 384,
    double scale = 1,
    bool settle = true,
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
        quizRepositoryProvider.overrideWithValue(repository),
        learningProfileRepositoryProvider.overrideWithValue(
          FakeLearningProfileRepository(),
        ),
        myWeakConceptsProvider.overrideWith((ref) async {
          weakLoads++;
          return [];
        }),
      ],
    );
    router = GoRouter(
      initialLocation: location ?? const WrongAnswersRoute().location,
      routes: $appRoutes,
    );
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
    if (settle) await tester.pumpAndSettle();
  }

  Future<void> preview(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('NOTE_PREVIEWS')) return;
    await tester.pumpAndSettle();
    final render =
        boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await render.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('/private/tmp/iquiz-note-$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  Future<void> openFirst(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('wrong_answer_101')));
    await tester.pumpAndSettle();
  }

  testWidgets('Figma 목록·자료 필터·아이콘 크기와 실제 API 데이터를 표시한다', (tester) async {
    await start(tester);
    expect(find.text('오답노트'), findsOneWidget);
    expect(find.byKey(const ValueKey('wrong_answer_101')), findsOneWidget);
    expect(find.byKey(const ValueKey('wrong_answer_102')), findsOneWidget);
    expect(find.text('TCP 연결 과정'), findsOneWidget);
    expect(find.text('PDF  4페이지'), findsOneWidget);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('wrong_answer_filter_all')))
          .height,
      closeTo(35.6, 1),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('wrong_answer_101'))).dy,
      closeTo(166.6, 1),
    );
    final search = find.descendant(
      of: find.byTooltip('오답 검색'),
      matching: find.byType(SvgPicture),
    );
    expect(tester.getSize(search), const Size(28, 28));
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey('wrong_answer_filter_all')))
          .dx,
      16,
    );
    expect(tester.getBottomRight(find.text('컴퓨터네트워크').last).dx, 368);
    final add = find.descendant(
      of: find.byTooltip('학습 자료 업로드'),
      matching: find.byType(SvgPicture),
    );
    expect(tester.getSize(add), const Size(34, 34));
    Finder navigationIcon(String label) => find.descendant(
      of: find
          .ancestor(of: find.text(label), matching: find.byType(InkWell))
          .first,
      matching: find.byType(SvgPicture),
    );
    expect(tester.getSize(navigationIcon('홈')), const Size(24, 24));
    expect(tester.getSize(navigationIcon('프로필')), const Size(24, 24));
    expect(tester.getSize(navigationIcon('노트')).width, 22);
    expect(
      tester.getSize(navigationIcon('노트')).height,
      closeTo(18.7946, 0.001),
    );
    await preview(tester, 'all');
    await tester.tap(find.byKey(const ValueKey('wrong_answer_filter_1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('wrong_answer_101')), findsOneWidget);
    expect(find.byKey(const ValueKey('wrong_answer_102')), findsNothing);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('wrong_answer_101'))).dy,
      closeTo(166.6, 1),
    );
    await preview(tester, 'filtered');
    expect(repository.loads, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('검색은 문제·개념·자료를 찾고 필터와 함께 적용한다', (tester) async {
    await start(tester);
    await tester.tap(find.byTooltip('오답 검색'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('wrong_answer_search')),
      '혼잡',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('wrong_answer_102')), findsOneWidget);
    expect(find.byKey(const ValueKey('wrong_answer_101')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('wrong_answer_filter_1')));
    await tester.pumpAndSettle();
    expect(find.text('검색 결과가 없어요'), findsOneWidget);
    expect(repository.loads, 1);
  });

  testWidgets('빈 목록·조회 오류·명시적 재시도를 구분한다', (tester) async {
    repository.loadError = Exception('offline');
    await start(tester);
    expect(find.text('오답노트를 불러오지 못했어요.'), findsOneWidget);
    expect(repository.loads, 1);
    repository.loadError = null;
    repository.wrongAnswers = [];
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    expect(find.text('학습 데이터가 더 필요해요'), findsOneWidget);
    expect(repository.loads, 2);
    await preview(tester, 'empty');
  });

  testWidgets('선택한 한 문제만 풀고 복습 API로 한 답안만 저장한다', (tester) async {
    await start(tester);
    await tester.tap(find.byKey(const ValueKey('wrong_answer_filter_1')));
    await openFirst(tester);
    expect(find.text('1 / 1'), findsOneWidget);
    expect(find.text('데이터를 조금씩 늘려 보내는 단계의 이름은?'), findsNothing);
    expect(find.text('다음 문제'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('quiz_option_1001')));
    await tester.pumpAndSettle();
    await preview(tester, 'correct');
    expect(repository.wrongAnswerReviewCount, 0);
    await tester.tap(find.text('복습 완료'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/wrong-answers');
    expect(repository.wrongAnswerReviewCount, 1);
    expect(repository.submitCount, 0);
    expect(repository.reviewedAnswers, hasLength(1));
    expect(repository.reviewedAnswers!.single.questionId, 101);
    expect(repository.reviewedAnswers!.single.optionId, 1001);
    expect(find.byKey(const ValueKey('wrong_answer_101')), findsNothing);
    // 복습 후에도 자료 필터를 유지하며 해결한 문제는 목록에서 제외
    expect(find.text('학습 데이터가 더 필요해요'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('wrong_answer_filter_all')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('wrong_answer_102')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('오답은 해설·근거를 표시하고 다른 보기 선택을 막으며 목록에 남긴다', (tester) async {
    await start(tester);
    await openFirst(tester);
    await tester.tap(find.byKey(const ValueKey('quiz_option_1002')));
    await tester.pumpAndSettle();
    expect(find.text('문제 해설'), findsOneWidget);
    expect(find.text('4페이지'), findsOneWidget);
    expect(find.text('연결 수립의 마지막 단계에서 ACK를 보낸다.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('quiz_option_1001')));
    await tester.pumpAndSettle();
    expect(find.text('문제 해설'), findsOneWidget);
    await preview(tester, 'wrong');
    await tester.tap(find.text('복습 완료'));
    await tester.pumpAndSettle();
    expect(repository.reviewedAnswers!.single.optionId, 1002);
    expect(find.byKey(const ValueKey('wrong_answer_101')), findsOneWidget);
    expect(repository.wrongAnswers.first.wrongCount, 3);
    expect(repository.loads, greaterThan(1));
  });

  testWidgets('제출 중 연타·뒤로가기를 차단하고 성공 후 관련 통계를 갱신한다', (tester) async {
    final pending = Completer<Result<QuizSubmissionEntity>>();
    repository.onSubmitWrongAnswerReview = () => pending.future;
    await start(tester);
    final materials = container.listen(myMaterialsProvider, (_, _) {});
    final detail = container.listen(
      myMaterialProvider(materialId: 1),
      (_, _) {},
    );
    final concepts = container.listen(
      myMaterialConceptsProvider(materialId: 1),
      (_, _) {},
    );
    final weak = container.listen(myWeakConceptsProvider, (_, _) {});
    addTearDown(materials.close);
    addTearDown(detail.close);
    addTearDown(concepts.close);
    addTearDown(weak.close);
    await tester.pumpAndSettle();
    final beforeMaterials = repository.materialsCount;
    final beforeDetail = repository.materialDetailRequests.length;
    final beforeConcepts = repository.conceptRequests.length;
    final beforeWeak = weakLoads;
    await openFirst(tester);
    await tester.tap(find.byKey(const ValueKey('quiz_option_1001')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('복습 완료'));
    await tester.pump();
    await tester.tap(find.text('결과 저장 중...'));
    await tester.tap(find.byTooltip('뒤로가기'));
    await tester.pump();
    expect(repository.wrongAnswerReviewCount, 1);
    expect(find.text('1 / 1'), findsOneWidget);
    pending.complete(Result.success(_submission(101, true)));
    await tester.pumpAndSettle();
    expect(repository.materialsCount, greaterThan(beforeMaterials));
    expect(repository.materialDetailRequests.length, greaterThan(beforeDetail));
    expect(repository.conceptRequests.length, greaterThan(beforeConcepts));
    expect(weakLoads, greaterThan(beforeWeak));
    expect(tester.takeException(), isNull);
  });

  testWidgets('응답 유실 시 자동 재제출 없이 목록을 다시 조회한다', (tester) async {
    repository.onSubmitWrongAnswerReview = () async =>
        Result.failure(Exception('timeout'));
    await start(tester);
    await openFirst(tester);
    await tester.tap(find.byKey(const ValueKey('quiz_option_1001')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('복습 완료'));
    await tester.pumpAndSettle();
    expect(find.text('오답노트로 돌아가기'), findsOneWidget);
    expect(repository.wrongAnswerReviewCount, 1);
    await tester.tap(find.text('오답노트로 돌아가기'));
    await tester.pumpAndSettle();
    expect(repository.wrongAnswerReviewCount, 1);
    expect(repository.loads, greaterThan(1));
    expect(find.byKey(const ValueKey('wrong_answer_101')), findsOneWidget);
  });

  testWidgets('답을 선택하지 않고 나가면 제출하지 않는다', (tester) async {
    await start(tester);
    await openFirst(tester);
    await tester.tap(find.byTooltip('뒤로가기'));
    await tester.pumpAndSettle();
    expect(repository.wrongAnswerReviewCount, 0);
    expect(find.byKey(const ValueKey('wrong_answer_101')), findsOneWidget);
  });

  testWidgets('직접 경로 진입은 목록에서 문제를 복원하고 OX도 한 문제만 표시한다', (tester) async {
    repository.wrongAnswers = [_item(ox: true)];
    await start(tester, location: '/wrong-answers/101');
    expect(find.text('1 / 1'), findsOneWidget);
    expect(find.bySemanticsLabel('O, 맞아요'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('quiz_option_1002')));
    await tester.pumpAndSettle();
    expect(find.text('문제 해설'), findsOneWidget);
    await preview(tester, 'ox');
  });

  testWidgets('좁은 화면과 큰 글씨·긴 문구도 넘침 없이 스크롤한다', (tester) async {
    repository.wrongAnswers = [_item(longText: true)];
    await start(tester, width: 320, scale: 1.5);
    expect(tester.takeException(), isNull);
    await openFirst(tester);
    final option = find.byKey(const ValueKey('quiz_option_1002'));
    await tester.ensureVisible(option);
    await tester.tap(option);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('복습 완료'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('홈·노트에서 프로필로 전환하고 로그아웃하면 캐시를 비운다', (tester) async {
    await start(tester, location: '/home');
    await tester.tap(find.text('노트'));
    await tester.pumpAndSettle();
    expect(find.text('오답노트'), findsOneWidget);
    await tester.tap(find.text('프로필'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('로그아웃'), findsOneWidget);
    await container.read(userAuthProvider.notifier).signOut();
    await tester.pumpAndSettle();
    expect(await container.read(myWrongAnswersProvider.future), isEmpty);
    expect(find.byKey(const ValueKey('wrong_answer_101')), findsNothing);
  });

  testWidgets('홈·노트·프로필을 같은 메인 PageView에서 전환한다', (tester) async {
    await start(tester, location: '/home');
    final main = tester.element(find.byType(MainPage));
    final location = router.routeInformationProvider.value.uri;
    await tester.tap(find.byKey(const ValueKey('main_tab_note')));
    await tester.pumpAndSettle();
    expect(find.text('오답노트'), findsOneWidget);
    expect(
      container.read(mainBottomNavigationProvider),
      MainNavigationTab.note,
    );
    expect(router.routeInformationProvider.value.uri, location);
    expect(tester.element(find.byType(MainPage)), same(main));
    final profile = find.byKey(const ValueKey('main_tab_profile'));
    expect(tester.widget<InkWell>(profile).onTap, isNotNull);
    await tester.tap(profile);
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('로그아웃'), findsOneWidget);
    expect(
      container.read(mainBottomNavigationProvider),
      MainNavigationTab.profile,
    );
    container
        .read(mainBottomNavigationProvider.notifier)
        .changeTab(MainNavigationTab.profile);
    await tester.pumpAndSettle();
    expect(
      container.read(mainBottomNavigationProvider),
      MainNavigationTab.profile,
    );
    expect(find.byType(ProfilePage), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('main_tab_home')));
    await tester.pumpAndSettle();
    expect(
      container.read(mainBottomNavigationProvider),
      MainNavigationTab.home,
    );
    expect(router.routeInformationProvider.value.uri, location);
  });

  testWidgets('탭을 왕복해도 노트의 검색·자료 필터를 유지하고 중복 조회하지 않는다', (tester) async {
    await start(tester);
    await tester.tap(find.byKey(const ValueKey('wrong_answer_filter_2')));
    await tester.tap(find.byTooltip('오답 검색'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('wrong_answer_search')),
      '혼잡',
    );
    await tester.pumpAndSettle();
    final noteLoads = repository.loads;
    final materialLoads = repository.materialsCount;
    for (final tab in ['profile', 'home', 'note']) {
      await tester.tap(find.byKey(ValueKey('main_tab_$tab')));
      await tester.pumpAndSettle();
    }
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('wrong_answer_search')))
          .controller!
          .text,
      '혼잡',
    );
    expect(find.byKey(const ValueKey('wrong_answer_102')), findsOneWidget);
    expect(find.byKey(const ValueKey('wrong_answer_101')), findsNothing);
    expect(find.byKey(const ValueKey('wrong_answer_103')), findsNothing);
    expect(repository.loads, noteLoads);
    expect(repository.materialsCount, materialLoads);
    // 검색어를 지워도 자료 필터는 그대로 남음
    await tester.tap(find.byTooltip('검색어 지우기'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('wrong_answer_103')), findsOneWidget);
    expect(find.byKey(const ValueKey('wrong_answer_101')), findsNothing);
  });

  testWidgets('홈에서 노트로 전환해 복습한 뒤에도 원래 메인과 자료 필터를 유지한다', (tester) async {
    await start(tester, location: '/home');
    final main = tester.element(find.byType(MainPage));
    await tester.tap(find.byKey(const ValueKey('main_tab_note')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('wrong_answer_filter_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('wrong_answer_102')));
    await tester.pumpAndSettle();
    expect(find.text('1 / 1'), findsOneWidget);
    expect(find.byKey(const ValueKey('main_tab_note')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('quiz_option_1001')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('복습 완료'));
    await tester.pumpAndSettle();
    expect(tester.element(find.byType(MainPage)), same(main));
    expect(
      container.read(mainBottomNavigationProvider),
      MainNavigationTab.note,
    );
    expect(find.byKey(const ValueKey('wrong_answer_102')), findsNothing);
    expect(find.byKey(const ValueKey('wrong_answer_103')), findsOneWidget);
    expect(find.byKey(const ValueKey('wrong_answer_101')), findsNothing);
    expect(repository.wrongAnswerReviewCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('홈 스크롤을 보존하고 좌우 스와이프로는 탭을 바꾸지 않는다', (tester) async {
    repository.materials = [
      for (var id = 1; id <= 25; id++) homeMaterial(id: id),
    ];
    await start(tester, location: '/home');
    final homeScroll = find.byKey(const PageStorageKey('home_quizzes'));
    await tester.drag(homeScroll, const Offset(0, -450));
    await tester.pumpAndSettle();
    final scrollable = find
        .descendant(of: homeScroll, matching: find.byType(Scrollable))
        .first;
    final position = tester.state<ScrollableState>(scrollable).position.pixels;
    expect(position, greaterThan(0));
    await tester.tap(find.byKey(const ValueKey('main_tab_note')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('main_tab_home')));
    await tester.pumpAndSettle();
    expect(tester.state<ScrollableState>(scrollable).position.pixels, position);
    await tester.drag(
      find.byKey(const ValueKey('main_pages')),
      const Offset(-300, 0),
    );
    await tester.pumpAndSettle();
    expect(
      container.read(mainBottomNavigationProvider),
      MainNavigationTab.home,
    );
    expect(find.text('오답노트'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('뒤로가기는 원래 노트를 유지하고 결과 화면의 홈 버튼은 홈 탭을 선택한다', (tester) async {
    await start(tester, location: '/home');
    await tester.tap(find.byKey(const ValueKey('main_tab_note')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('학습 자료 업로드'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('main_tab_note')), findsNothing);
    await tester.tap(find.byTooltip('뒤로가기'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, HomeRoute.path);
    expect(
      container.read(mainBottomNavigationProvider),
      MainNavigationTab.note,
    );
    expect(find.text('오답노트'), findsOneWidget);
    unawaited(
      router.push<void>(
        const QuizResultRoute(7).location,
        extra: QuizResultRouteArg(
          quiz: testQuiz,
          submission: testSubmission,
          answers: testAnswers,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '홈'));
    await tester.pumpAndSettle();
    expect(
      container.read(mainBottomNavigationProvider),
      MainNavigationTab.home,
    );
    expect(find.text('오답노트'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _ReviewRepository extends FakeQuizRepository {
  int loads = 0;
  Exception? loadError;

  @override
  Future<Result<List<WrongAnswerEntity>>> getMyWrongAnswers() async {
    loads++;
    return loadError == null
        ? Result.success(wrongAnswers)
        : Result.failure(loadError!);
  }

  @override
  Future<Result<QuizSubmissionEntity>> submitWrongAnswerReview({
    required List<QuizAnswerEntity> answers,
  }) async {
    final answer = answers.single;
    final correct = answer.optionId == 1001;
    onSubmitWrongAnswerReview ??= () async =>
        Result.success(_submission(answer.questionId, correct));
    final result = await super.submitWrongAnswerReview(answers: answers);
    result.fold(
      onSuccess: (_) {
        wrongAnswers = [
          for (final item in wrongAnswers)
            if (item.questionId != answer.questionId)
              item
            else if (!correct)
              _item(id: item.questionId, wrongCount: item.wrongCount + 1),
        ];
      },
      onFailure: (_) {},
    );
    return result;
  }
}

QuizSubmissionEntity _submission(int id, bool correct) => QuizSubmissionEntity(
  submissionId: 500,
  correctCount: correct ? 1 : 0,
  totalCount: 1,
  results: [QuizQuestionResultEntity(questionId: id, correct: correct)],
);

WrongAnswerEntity _item({
  int id = 101,
  int wrongCount = 2,
  bool ox = false,
  bool longText = false,
}) => WrongAnswerEntity(
  questionId: id,
  quizId: id == 101 ? 7 : 8,
  format: ox ? .ox : .multipleChoice,
  content: longText
      ? List.filled(5, 'SYN+ACK를 받은 클라이언트는 다음에 무엇을 보낼까요?').join(' ')
      : id == 101
      ? 'SYN+ACK를 받은 클라이언트는 다음에 무엇을 보낼까요?'
      : id == 102
      ? '데이터를 조금씩 늘려 보내는 단계의 이름은?'
      : '각 프로세스가 4ms씩 번갈아 실행될 때 P2는 몇 ms 기다릴까요?',
  cognitiveType: .apply,
  conceptName: longText
      ? List.filled(6, '아주 긴 개념명').join(' ')
      : id == 101
      ? 'TCP 연결 과정'
      : id == 102
      ? '혼잡 제어'
      : '프로세스 순서 정하기',
  materialId: id == 101 ? 1 : 2,
  materialTitle: longText
      ? List.filled(6, '아주 긴 자료명').join(' ')
      : id == 101
      ? '컴퓨터네트워크'
      : '운영체제',
  explanation: '연결의 마지막 단계는 ACK다.',
  sourceQuote: '연결 수립의 마지막 단계에서 ACK를 보낸다.',
  sourcePageNo: id == 101
      ? 4
      : id == 102
      ? 9
      : null,
  options: ox
      ? [
          const .new(optionId: 1001, content: 'O', isCorrect: true),
          const .new(optionId: 1002, content: 'X', isCorrect: false),
        ]
      : testQuiz.questions.first.options,
  wrongCount: wrongCount,
  lastWrongAt: DateTime(2026, 3, 12, 12),
);
