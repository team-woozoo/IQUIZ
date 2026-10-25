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
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_submission_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_question_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_question_result_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_answer_entity.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_result/quiz_result_page.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_result/providers/quiz_result_route_arg.dart';
import 'package:iquiz/features/learning_profile/repositories/enums/cognitive_type.enum.dart';

import '../support/quiz_fakes.dart';

void main() {
  late FakeQuizRepository repository;
  late GoRouter router;
  late GlobalKey boundary;

  setUpAll(() async {
    await (FontLoader('pretendard')..addFont(
          rootBundle.load('assets/fonts/pretendard/Pretendard-Regular.otf'),
        ))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  Future<void> start(WidgetTester tester, {String? location}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    repository = FakeQuizRepository();
    router = GoRouter(
      initialLocation: location ?? const QuizRoute(7).location,
      routes: $appRoutes,
    );
    addTearDown(router.dispose);
    boundary = GlobalKey();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [quizRepositoryProvider.overrideWithValue(repository)],
        child: RepaintBoundary(
          key: boundary,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            theme: AppTheme.light,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final target = find.text(text).last;
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  Future<void> finish(WidgetTester tester, {bool submit = true}) async {
    await tapText(tester, '보기 B');
    await tapText(tester, '다음 문제');
    await tapText(tester, '보기 D');
    if (submit) await tapText(tester, '결과 보기');
  }

  testWidgets('마지막 문제에서 한 번 제출하고 서버 점수·개념별 결과를 표시한다', (tester) async {
    await start(tester);
    final pending = Completer<Result<QuizSubmissionEntity>>();
    repository.onSubmit = () => pending.future;
    await finish(tester, submit: false);
    expect(repository.submitCount, 0);
    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('결과 보기'),
        matching: find.byType(FilledButton),
      ),
    );
    button.onPressed!();
    button.onPressed!();
    await tester.pump();
    expect(repository.submitCount, 1);
    expect(
      router.routeInformationProvider.value.uri.path,
      const QuizRoute(7).location,
    );

    pending.complete(Result.success(testSubmission));
    await tester.pumpAndSettle();
    expect(find.byType(QuizResultPage), findsOneWidget);
    expect(
      GoRouterState.of(tester.element(find.byType(QuizResultPage))).uri.path,
      const QuizResultRoute(7).location,
    );
    expect(find.text('모든 문제를 풀었어요!'), findsOneWidget);
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('quiz_result_count_0')))
          .data,
      '2',
    );
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('quiz_result_count_1')))
          .data,
      '1',
    );
    expect(find.text('1문제 틀렸어요'), findsOneWidget);
    expect(find.byKey(const ValueKey('quiz_result_wrong_badge')), findsNothing);
    expect(find.text('완벽해요'), findsOneWidget);
    expect(repository.submittedAnswers!.map((answer) => answer.optionId), [
      1002,
      2002,
    ]);
    expect(tester.takeException(), isNull);

    if (const bool.fromEnvironment('QUIZ_RESULT_PREVIEWS')) {
      final render =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await render.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('/private/tmp/iquiz-quiz-result.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    router.pop();
    await tester.pumpAndSettle();
    await tapText(tester, '결과 보기');
    expect(find.byType(QuizResultPage), findsOneWidget);
    expect(repository.submitCount, 1);

    await tapText(tester, '다시 풀기');
    await finish(tester);
    expect(repository.submitCount, 2);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('완료 화면은 주제별 문제 수와 전체 폭 요약·고정 학습 안내를 표시한다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    const topics = [
      (name: 'TCP 연결 과정', pages: [4, 5, 5]),
      (name: '혼잡 제어', pages: [9]),
      (name: 'UDP 특징', pages: [3, 3]),
      (name: '흐름 제어', pages: [7, 8]),
      (name: '연결 종료 과정', pages: [6, 6]),
    ];
    final questions = <QuizQuestionEntity>[];
    for (final topic in topics) {
      for (final page in topic.pages) {
        questions.add(
          QuizQuestionEntity(
            questionId: questions.length + 1,
            content: '문제',
            conceptName: topic.name,
            explanation: '해설',
            sourceQuote: '근거',
            sourcePageNo: page,
            cognitiveType: CognitiveType.apply,
            options: testQuiz.questions.first.options,
          ),
        );
      }
    }
    final data = QuizResultRouteArg(
      quiz: QuizEntity(
        quizId: 7,
        materialId: 1,
        format: testQuiz.format,
        difficulty: testQuiz.difficulty,
        questions: questions,
      ),
      materialTitle: '컴퓨터 네트워크 4주차',
      submission: QuizSubmissionEntity(
        submissionId: 1,
        correctCount: 7,
        totalCount: 10,
        results: [
          for (final question in questions)
            QuizQuestionResultEntity(
              questionId: question.questionId,
              correct: ![1, 2, 4].contains(question.questionId),
            ),
        ],
      ),
      answers: [
        for (final question in questions)
          QuizAnswerEntity(questionId: question.questionId, optionId: 1001),
      ],
    );
    for (final width in [384.0, 320.0]) {
      tester.view.physicalSize = Size(width, 832);
      boundary = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          child: RepaintBoundary(
            key: boundary,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(width == 320 ? 1.5 : 1),
                ),
                child: child!,
              ),
              home: QuizResultPage(quizId: 7, result: data),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('3문제'), findsOneWidget);
      expect(find.text('2문제 틀렸어요'), findsOneWidget);
      expect(find.text('응용 문제를 많이 틀렸어요'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('quiz_result_wrong_badge')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
      if (width == 384) {
        final summary = find
            .ancestor(
              of: find.byKey(const ValueKey('quiz_result_count_0')),
              matching: find.byType(ColoredBox),
            )
            .first;
        expect(tester.getSize(summary).width, 384);
        expect(tester.getTopLeft(summary).dy, closeTo(209, 1));
        expect(
          tester.getBottomLeft(find.widgetWithText(FilledButton, '홈')).dy,
          784,
        );
        if (const bool.fromEnvironment('QUIZ_RESULT_PREVIEWS')) {
          final render =
              boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await render.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File('/private/tmp/iquiz-quiz-result-design.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      }
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('제출 실패는 마지막 문제에 표시하고 재시도가 성공하면 결과로 이동한다', (tester) async {
    await start(tester);
    repository.onSubmit = () async => Result.failure(
      const InvalidSubmissionException(detail: '다른 문제의 보기입니다.'),
    );
    await finish(tester);
    expect(find.text('다른 문제의 보기입니다.'), findsOneWidget);
    expect(find.byType(QuizResultPage), findsNothing);
    expect(repository.submitCount, 1);
    repository.onSubmit = null;
    await tapText(tester, '결과 보기');
    expect(find.byType(QuizResultPage), findsOneWidget);
    expect(repository.submitCount, 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('결과 URL에 직접 접근해도 답안을 임의로 제출하지 않는다', (tester) async {
    await start(tester, location: const QuizResultRoute(7).location);
    expect(find.byType(QuizResultPage), findsOneWidget);
    expect(find.text('풀이 결과 정보가 없습니다.\n퀴즈를 풀고 결과를 확인해 주세요.'), findsOneWidget);
    expect(repository.submitCount, 0);
    await tapText(tester, '퀴즈 풀기');
    expect(
      router.routeInformationProvider.value.uri.path,
      const QuizRoute(7).location,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
