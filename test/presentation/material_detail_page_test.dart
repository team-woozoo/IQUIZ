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
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/app/style/app_theme.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/core/services/app_size.dart';
import 'package:iquiz/core/services/bounce_tapper.dart';
import 'package:iquiz/presentation/widgets/button/base_bottom_navigation_bar.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/quiz/repositories/entities/material_concept_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_last_submission_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_summary_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/study_material_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_job_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/material_concept_state.enum.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_format.enum.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_difficulty.enum.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/quiz_play_page.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_upload/quiz_upload_page.dart';
import 'package:iquiz/presentation/providers/material/material_providers.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';

import '../support/home_fakes.dart';
import '../support/quiz_fakes.dart';

void main() {
  late FakeQuizRepository repository;
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
    repository = FakeQuizRepository()
      ..materials = [_material()]
      ..concepts = {
        1: [
          _concept(1, 'TCP 연결 과정', [4, 5], .weak, count: 3),
          _concept(2, '혼잡 제어', [9, 10], .weak, count: 5),
          _concept(3, 'UDP 특징', [3], .perfect),
          _concept(4, '흐름 제어', [7, 8], .perfect),
          _concept(5, '연결 종료 과정', [6], .unchecked, count: 2),
        ],
      }
      ..quizzes = [
        _quiz(7, 21, 10, 7),
        _quiz(8, 18, 5, 3),
        _quiz(9, 15, 10, 9, ox: true),
        _quiz(10, 14, 5, 2),
      ];
  });

  Future<void> start(
    WidgetTester tester, {
    bool settle = true,
    double width = 384,
    double textScale = 1,
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
      ],
    );
    router = GoRouter(
      initialLocation: const MaterialDetailRoute(1).location,
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
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(textScale),
                  disableAnimations: true,
                ),
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
    if (!const bool.fromEnvironment('MATERIAL_PREVIEWS')) return;
    await tester.pumpAndSettle();
    final render =
        boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final previous = debugDisableShadows;
    try {
      debugDisableShadows = false;
      render.reassemble();
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final image = await render.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('/private/tmp/iquiz-material-$name.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    } finally {
      debugDisableShadows = previous;
    }
  }

  Future<void> tapMaterialAction(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(ValueKey(key)));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
  }

  Future<void> tapUploadAction(WidgetTester tester, String title) async {
    await tester.tap(find.widgetWithText(BaseBottomNavigationBar, title));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
  }

  testWidgets('분석 화면은 실제 자료와 오답·미풀이를 구분하고 디자인의 배치를 유지한다', (tester) async {
    await start(tester);
    expect(find.text('컴퓨터네트워크 4주차'), findsOneWidget);
    expect(find.text('PDF · 10월 14일'), findsNothing);
    for (final entry in {0: '30', 1: '20', 2: '8', 3: '2'}.entries) {
      expect(
        tester
            .widget<Text>(find.byKey(ValueKey('material_count_${entry.key}')))
            .data,
        entry.value,
      );
    }
    expect(find.text('PDF 4~5 페이지'), findsOneWidget);
    expect(find.text('부족해요'), findsNWidgets(2));
    expect(find.text('완벽해요'), findsNWidgets(2));
    expect(find.text('정보가 없어요'), findsOneWidget);
    expect(find.text('10문제'), findsNWidgets(2));
    expect(find.text('3문제'), findsOneWidget);
    expect(find.text('5문제'), findsOneWidget);
    expect(repository.materialDetailRequests, [1]);
    expect(repository.conceptRequests, [1]);
    expect(repository.quizMaterialFilters, isEmpty);
    final playButton = find.byKey(const ValueKey('material_play_button'));
    expect(tester.getSize(playButton).width, 171);
    expect(tester.getSize(playButton).height, closeTo(52, 0.01));
    expect(tester.getBottomLeft(playButton), const Offset(16, 798));
    final generateButton = find.byKey(
      const ValueKey('material_generate_button'),
    );
    expect(tester.getSize(generateButton), tester.getSize(playButton));
    expect(tester.getBottomLeft(generateButton), const Offset(197, 798));
    final summary = find.byKey(const ValueKey('material_count_0'));
    final summaryBackground = find
        .ancestor(of: summary, matching: find.byType(ColoredBox))
        .first;
    expect(tester.getTopLeft(summaryBackground), const Offset(16, 108));
    expect(tester.getSize(summaryBackground).width, 352);
    expect(tester.widget<Text>(summary).style!.fontWeight, FontWeight.w600);
    final title = find.byKey(const ValueKey('material_title'));
    expect(tester.widget<Text>(title).style!.fontSize, 20);
    expect(tester.getCenter(title), const Offset(192, 72));
    final analysisTab = find.byKey(const ValueKey('material_tab_0'));
    final historyTab = find.byKey(const ValueKey('material_tab_1'));
    expect(tester.getSize(analysisTab), const Size(173, 36));
    expect(tester.getSize(historyTab), tester.getSize(analysisTab));
    expect(tester.getTopLeft(analysisTab).dx, 19);
    expect(tester.getTopLeft(analysisTab).dy, closeTo(240.8, 1));
    expect(tester.getTopLeft(find.text('TCP 연결 과정')).dy, closeTo(320.8, 1));
    expect(tester.takeException(), isNull);
    await preview(tester, 'analysis');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('기록 탭은 해당 자료만 조회하고 퀴즈 선택·복귀 시 탭을 유지한다', (tester) async {
    await start(tester);
    await tester.tap(find.text('기록'));
    await tester.pumpAndSettle();
    expect(repository.quizMaterialFilters, [1]);
    expect(find.byKey(const ValueKey('material_play_button')), findsOneWidget);
    expect(find.text('10월 21일 (화)'), findsOneWidget);
    expect(find.text('7 / 10'), findsOneWidget);
    expect(find.text('2 / 5'), findsOneWidget);
    expect(find.text('OX · 10문제'), findsOneWidget);
    await preview(tester, 'history');
    await tester.tap(find.byKey(const ValueKey('material_quiz_7')));
    await tester.pumpAndSettle();
    expect(find.byType(QuizPlayPage), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('7 / 10'), findsOneWidget);
    expect(find.text('TCP 연결 과정'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('기존 문제는 해당 자료의 퀴즈 선택 창을 열고 선택한 퀴즈로 이동한다', (tester) async {
    await start(tester);
    final button = find.byKey(const ValueKey('material_play_button'));
    final onPressed = tester
        .widget<BounceTapper>(
          find.descendant(of: button, matching: find.byType(BounceTapper)),
        )
        .onTap!;
    onPressed();
    onPressed();
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('풀 퀴즈 선택'), findsOneWidget);
    expect(repository.quizMaterialFilters, [1]);
    await preview(tester, 'quiz-selection');
    final target = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byKey(const ValueKey('material_quiz_9')),
    );
    await tester.tap(target);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(QuizPlayPage), findsOneWidget);
    expect(
      GoRouterState.of(tester.element(find.byType(QuizPlayPage))).uri.path,
      const QuizRoute(9).location,
    );
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('TCP 연결 과정'), findsOneWidget);
    expect(
      tester
          .widget<BounceTapper>(
            find.descendant(of: button, matching: find.byType(BounceTapper)),
          )
          .onTap,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('문제 생성은 생성 화면을 열고 복귀하면 자료 상세를 유지한다', (tester) async {
    await start(tester);
    await tester.tap(find.text('기록'));
    await tester.pumpAndSettle();
    await tapMaterialAction(tester, 'material_generate_button');
    await tester.pumpAndSettle();
    expect(find.byType(QuizUploadPage), findsOneWidget);
    expect(
      tester.widget<QuizUploadPage>(find.byType(QuizUploadPage)).materialId,
      1,
    );
    expect(find.text('현재 자료로 문제를 생성해요'), findsOneWidget);
    expect(find.text('파일을 업로드해주세요'), findsNothing);
    await preview(tester, 'existing-material-generation');
    await tester.tap(find.byTooltip('뒤로가기').last);
    await tester.pumpAndSettle();
    expect(find.text('7 / 10'), findsOneWidget);
    expect(find.text('기존 문제'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('현재 자료로 한 번 생성하고 완료 후 새 퀴즈와 자료 기록을 확인한다', (tester) async {
    final jobs = StreamController<Result<QuizGenerationJobEntity>>();
    addTearDown(jobs.close);
    repository.onWatchGeneration = () => jobs.stream;
    await start(tester);
    await tester.tap(find.text('기록'));
    await tester.pumpAndSettle();
    await tapMaterialAction(tester, 'material_generate_button');
    await tester.pumpAndSettle();
    await tester.tap(find.text('문제 유형'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OX 퀴즈'));
    await tapUploadAction(tester, '선택 완료');
    await tester.pumpAndSettle();
    await tester.tap(find.text('난이도'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('어려움'));
    await tapUploadAction(tester, '선택 완료');
    await tester.pumpAndSettle();
    final generate = tester
        .widget<BaseBottomNavigationBar>(
          find.widgetWithText(BaseBottomNavigationBar, '문제 생성'),
        )
        .onBtnClicked!;
    generate();
    generate();
    await tester.pumpAndSettle();
    expect(repository.materialGenerationRequests, [1]);
    expect(repository.uploadRequests, 0);
    expect(repository.materialGenerationOptions?.format, QuizFormat.ox);
    expect(
      repository.materialGenerationOptions?.difficulty,
      QuizDifficulty.hard,
    );
    expect(find.text('문제 풀기'), findsNothing);
    repository.quizzes = [...repository.quizzes, _quiz(11, 24, 10, 8)];
    jobs.add(
      Result.success(
        const QuizGenerationJobEntity(jobId: 11, status: .done, quizId: 11),
      ),
    );
    await tester.pumpAndSettle();
    await tapUploadAction(tester, '문제 풀기');
    await tester.pumpAndSettle();
    expect(find.byType(QuizPlayPage), findsOneWidget);
    expect(
      GoRouterState.of(tester.element(find.byType(QuizPlayPage))).uri.path,
      const QuizRoute(11).location,
    );
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('문제 풀기'), findsOneWidget);
    await tester.tap(find.byTooltip('뒤로가기').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('material_quiz_11')), findsOneWidget);
    expect(repository.materialGenerationRequests, [1]);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('현재 자료 생성 실패는 자동 재요청하지 않고 명시적인 재시도만 허용한다', (tester) async {
    final jobs = StreamController<Result<QuizGenerationJobEntity>>();
    addTearDown(jobs.close);
    repository.onWatchGeneration = () => jobs.stream;
    repository.onMaterialGeneration = () async => Result.failure(
      const GenerationInProgressException(detail: '이미 생성 중이에요.'),
    );
    await start(tester);
    await tapMaterialAction(tester, 'material_generate_button');
    await tester.pumpAndSettle();
    await tapUploadAction(tester, '문제 생성');
    await tester.pumpAndSettle();
    expect(find.text('이미 생성 중이에요.'), findsOneWidget);
    expect(repository.materialGenerationRequests, [1]);
    repository.onMaterialGeneration = () async => Result.success(11);
    await tapUploadAction(tester, '다시 시도');
    await tester.pumpAndSettle();
    expect(repository.materialGenerationRequests, [1, 1]);
    expect(repository.uploadRequests, 0);
    jobs.add(
      Result.success(
        const QuizGenerationJobEntity(jobId: 11, status: .done, quizId: 11),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('문제 풀기'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('퀴즈가 없으면 선택 창에서 안내하고 닫은 뒤 버튼을 다시 사용할 수 있다', (tester) async {
    repository.quizzes = [];
    await start(tester);
    await tapMaterialAction(tester, 'material_play_button');
    await tester.pumpAndSettle();
    expect(find.text('아직 생성한 퀴즈가 없어요.'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    await tapMaterialAction(tester, 'material_play_button');
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('퀴즈 선택 창의 로딩·오류·재시도를 처리한다', (tester) async {
    final pending = Completer<Result<List<QuizSummaryEntity>>>();
    repository.onGetMyQuizzes = () => pending.future;
    await start(tester);
    tester
        .widget<BounceTapper>(
          find.descendant(
            of: find.byKey(const ValueKey('material_play_button')),
            matching: find.byType(BounceTapper),
          ),
        )
        .onTap!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(Result.failure(Exception('offline')));
    await tester.pumpAndSettle();
    expect(find.text('다시 시도'), findsOneWidget);
    repository.onGetMyQuizzes = null;
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    expect(find.text('7 / 10'), findsOneWidget);
    expect(repository.quizMaterialFilters, [1, 1]);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('보통 상태와 비연속 페이지·미풀이 기록을 처리한다', (tester) async {
    repository.concepts = {
      1: [
        _concept(1, '비연속 개념', [3, 4, 7], .good),
      ],
    };
    repository.quizzes = [homeQuiz()];
    await start(tester);
    expect(find.text('PDF 3~4, 7 페이지'), findsOneWidget);
    expect(find.text('보통'), findsOneWidget);
    await tester.tap(find.text('기록'));
    await tester.pumpAndSettle();
    expect(find.text('– / 10'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('자료 로딩·404·재시도를 처리한다', (tester) async {
    final pending = Completer<Result<StudyMaterialEntity>>();
    repository.onGetMyMaterial = (_) => pending.future;
    await start(tester, settle: false);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(Result.failure(const MaterialNotFoundException()));
    await tester.pumpAndSettle();
    expect(find.text('자료를 찾을 수 없어요.'), findsOneWidget);
    expect(find.text('문제'), findsNothing);
    repository.onGetMyMaterial = null;
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    expect(find.text('컴퓨터네트워크 4주차'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('개념 조회 오류가 있어도 머리글과 기록 탭을 사용할 수 있다', (tester) async {
    repository.onGetMyMaterialConcepts = (_) async =>
        Result.failure(Exception('offline'));
    await start(tester);
    expect(find.text('컴퓨터네트워크 4주차'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
    await tester.tap(find.text('기록'));
    await tester.pumpAndSettle();
    expect(find.text('7 / 10'), findsOneWidget);
    await tester.tap(find.text('분석'));
    await tester.pumpAndSettle();
    repository.onGetMyMaterialConcepts = null;
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    expect(find.text('TCP 연결 과정'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('빈 개념·기록을 안내하고 새로고침하면 모든 통계를 갱신한다', (tester) async {
    repository.concepts = {};
    repository.quizzes = [];
    await start(tester);
    expect(find.text('아직 분석할 개념이 없어요.'), findsOneWidget);
    await tester.tap(find.text('기록'));
    await tester.pumpAndSettle();
    expect(find.text('아직 생성한 퀴즈가 없어요.'), findsOneWidget);
    repository.materials = [_material(correct: 21)];
    repository.quizzes = [_quiz(7, 21, 10, 8)];
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('material_count_1'))).data,
      '21',
    );
    expect(find.text('8 / 10'), findsOneWidget);
    expect(repository.materialDetailRequests, hasLength(2));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('외부 통계 무효화 시 상세 집계를 갱신한다', (tester) async {
    await start(tester);
    repository.materials = [_material(correct: 22)];
    container.invalidate(myMaterialProvider(materialId: 1));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('material_count_1'))).data,
      '22',
    );
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('material_count_2'))).data,
      '6',
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('좁은 화면·큰 글자·긴 자료명에서도 넘치지 않는다', (tester) async {
    repository.materials = [
      _material(title: '아주 긴 컴퓨터네트워크 강의 자료와 데이터베이스 동시성 제어 정리'),
    ];
    await start(tester, width: 320, textScale: 1.5);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('기록'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await preview(tester, 'narrow');
    await tester.pumpWidget(const SizedBox());
  });
}

StudyMaterialEntity _material({
  int correct = 20,
  String title = '컴퓨터네트워크 4주차',
}) => StudyMaterialEntity(
  materialId: 1,
  title: title,
  originalFilename: 'network.pdf',
  pageCount: 12,
  createdAt: DateTime(2025, 10, 14),
  questionCount: 30,
  answeredCount: 28,
  correctCount: correct,
  wrongCount: 30 - correct,
  accuracy: correct / 30,
  generating: false,
);

MaterialConceptEntity _concept(
  int id,
  String name,
  List<int> pages,
  MaterialConceptState status, {
  int count = 10,
}) => MaterialConceptEntity(
  conceptId: id,
  conceptName: name,
  pageNos: pages,
  questionCount: count,
  answeredCount: status == MaterialConceptState.unchecked ? 0 : count,
  correctCount: status == MaterialConceptState.perfect ? count : 0,
  accuracy: status == MaterialConceptState.perfect ? 1 : 0,
  status: status,
);

QuizSummaryEntity _quiz(
  int id,
  int day,
  int total,
  int correct, {
  bool ox = false,
}) => QuizSummaryEntity(
  quizId: id,
  materialId: 1,
  materialTitle: '컴퓨터네트워크 4주차',
  format: ox ? .ox : .multipleChoice,
  difficulty: .normal,
  questionCount: total,
  createdAt: DateTime(2025, 10, day),
  submissionCount: 1,
  lastSubmission: QuizLastSubmissionEntity(
    correctCount: correct,
    submittedAt: DateTime(2025, 10, day, 12),
  ),
);
