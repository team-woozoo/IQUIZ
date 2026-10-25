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
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/app/style/app_theme.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_option_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_question_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_question_result_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_submission_entity.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_result/providers/quiz_result_route_arg.dart';
import 'package:iquiz/presentation/pages/quiz/widgets/quiz_feedback.dart';

import '../support/quiz_fakes.dart';

void main() {
  late GoRouter router;
  late GlobalKey boundary;
  late FakeQuizRepository repository;

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
          )
          ..addFont(
            rootBundle.load('assets/fonts/pretendard/Pretendard-Bold.otf'),
          ))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  Future<void> start(
    WidgetTester tester, {
    bool ox = false,
    bool xCorrect = false,
    double width = 384,
    double scale = 1,
    bool longText = false,
  }) async {
    tester.view.physicalSize = Size(width, 832);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    repository = FakeQuizRepository()
      ..quiz = _quiz(ox: ox, xCorrect: xCorrect, longText: longText);
    router = GoRouter(
      initialLocation: const QuizRoute(7, title: '컴퓨터 네트워크 4주차').location,
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
            theme: AppTheme.light,
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> preview(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('QUIZ_PLAY_PREVIEWS')) return;
    await tester.runAsync(
      () => precacheImage(
        const AssetImage('assets/icons/quiz_source_pdf.png'),
        boundary.currentContext!,
      ),
    );
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
        await File('/private/tmp/iquiz-play-$name.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    } finally {
      debugDisableShadows = previous;
    }
  }

  BoxDecoration? outline(WidgetTester tester, int optionId) =>
      tester
              .widget<Container>(
                find.descendant(
                  of: find.byKey(ValueKey('quiz_option_$optionId')),
                  matching: find.byType(Container),
                ),
              )
              .foregroundDecoration
          as BoxDecoration?;

  testWidgets('객관식은 개념 텍스트·20px 문제·18px 보기와 56 높이 카드를 표시한다', (tester) async {
    await start(tester);
    expect(find.text('1 / 10'), findsOneWidget);
    expect(find.text('TCP 연결 과정'), findsOneWidget);
    expect(find.text('정답 확인'), findsNothing);
    expect(find.text('다음 문제'), findsNothing);
    final option = find.byKey(const ValueKey('quiz_option_1001'));
    expect(tester.getSize(option), const Size(352, 56));
    expect(tester.getTopLeft(option).dy, closeTo(252.75, 1));
    final question = tester.widget<Text>(
      find.text(repository.quiz.questions.first.content),
    );
    expect(question.style!.fontSize, 20);
    expect(question.style!.fontWeight, FontWeight.w500);
    final concept = tester.widget<Text>(find.text('TCP 연결 과정'));
    expect(concept.style!.fontSize, 15);
    expect(concept.style!.fontWeight, FontWeight.w400);
    expect(concept.style!.color, AppColor.secondaryText);
    expect(
      tester.getTopLeft(find.text(repository.quiz.questions.first.content)).dy -
          tester.getBottomLeft(find.text('TCP 연결 과정')).dy,
      12,
    );
    final label = tester.widget<Text>(find.text('SYN'));
    expect(label.style!.fontSize, 18);
    expect(label.style!.fontWeight, FontWeight.w400);
    final number = tester.widget<Text>(find.text('1'));
    expect(number.style!.fontWeight, FontWeight.w600);
    await preview(tester, 'multiple-choice');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('오답을 누르면 즉시 정오답과 PDF 근거를 표시하고 답 변경을 막는다', (tester) async {
    await start(tester);
    final before = {
      for (final id in [1001, 1002, 1003, 1004])
        id: tester.getRect(find.byKey(ValueKey('quiz_option_$id'))),
    };
    await tester.tap(find.text('SYN'));
    await tester.pumpAndSettle();
    expect(find.text('문제 해설'), findsOneWidget);
    expect(find.text('정답: 2번 ACK'), findsNothing);
    expect(find.text('4페이지'), findsOneWidget);
    expect(find.text('다음 문제'), findsOneWidget);
    expect(find.text(_quote), findsOneWidget);
    final heading = find.text('문제 해설');
    final badge = find.byKey(const ValueKey('quiz_feedback_source_badge'));
    expect(tester.widget<Text>(heading).style!.fontWeight, FontWeight.w600);
    expect(tester.widget<Text>(heading).style!.color, AppColor.dark);
    expect(tester.getCenter(heading).dy, tester.getCenter(badge).dy);
    expect(tester.getTopRight(badge).dx, 364);
    expect(
      tester
              .getTopLeft(
                find.byKey(const ValueKey('quiz_feedback_explanation')),
              )
              .dy -
          tester.getBottomLeft(badge).dy,
      closeTo(16, 0.01),
    );
    expect(
      (outline(tester, 1001)!.border! as Border).top.color,
      AppColor.danger,
    );
    expect((outline(tester, 1001)!.border! as Border).top.strokeOutset, 0);
    expect(outline(tester, 1002), isNull);
    expect(
      tester.getSize(find.byKey(const ValueKey('quiz_feedback_source_icon'))),
      const Size(14, 14),
    );
    for (final entry in before.entries) {
      expect(
        tester.getRect(find.byKey(ValueKey('quiz_option_${entry.key}'))),
        entry.value,
      );
    }
    expect(
      tester
          .widget<FilledButton>(find.byType(FilledButton))
          .style!
          .backgroundColor!
          .resolve({}),
      AppColor.primaryAction,
    );
    await preview(tester, 'wrong');
    await tester.tap(find.text('ACK'));
    await tester.pumpAndSettle();
    expect(find.text('문제 해설'), findsOneWidget);
    expect(
      (outline(tester, 1001)!.border! as Border).top.color,
      AppColor.danger,
    );
    await tester.tap(find.text('다음 문제'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 10'), findsOneWidget);
    expect(find.text('다음 문제'), findsNothing);
    expect(repository.submitCount, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('정답을 누르면 정답 보기와 다음 버튼을 표시하며 오답 해설 시트는 열지 않는다', (tester) async {
    await start(tester);
    final before = {
      for (final id in [1001, 1002, 1003, 1004])
        id: tester.getRect(find.byKey(ValueKey('quiz_option_$id'))),
    };
    await tester.tap(find.text('ACK'));
    await tester.pumpAndSettle();
    expect(find.text('다음 문제'), findsOneWidget);
    expect(find.text('4페이지'), findsNothing);
    expect(find.text('정답: 2번 ACK'), findsNothing);
    expect(find.text('문제 해설'), findsNothing);
    expect(
      (outline(tester, 1002)!.border! as Border).top.color,
      AppColor.success,
    );
    for (final entry in before.entries) {
      expect(
        tester.getRect(find.byKey(ValueKey('quiz_option_${entry.key}'))),
        entry.value,
      );
    }
    await preview(tester, 'correct');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('OX는 180 높이 카드로 표시하고 오답 선택 시 실제 정답을 보여준다', (tester) async {
    await start(tester, ox: true);
    final option = find.byKey(const ValueKey('quiz_option_1001'));
    final originalRect = tester.getRect(option);
    expect(tester.getSize(option), const Size(170, 180));
    expect(
      originalRect.top -
          tester
              .getBottomLeft(find.text(repository.quiz.questions.first.content))
              .dy,
      31,
    );
    expect(find.text('맞아요'), findsNothing);
    expect(find.text('아니에요'), findsNothing);
    expect(find.bySemanticsLabel('O, 맞아요'), findsOneWidget);
    final icon = find.descendant(of: option, matching: find.byType(SvgPicture));
    expect(tester.getSize(icon), const Size(70, 70));
    expect(tester.getCenter(icon), originalRect.center);
    expect(
      (outline(tester, 1001)!.border! as Border).top.color,
      AppColor.surfaceSubtle,
    );
    expect(
      (outline(tester, 1002)!.border! as Border).top.color,
      AppColor.surfaceSubtle,
    );
    await preview(tester, 'ox');
    await tester.tap(find.byKey(const ValueKey('quiz_option_1002')));
    await tester.pumpAndSettle();
    expect(find.text('문제 해설'), findsOneWidget);
    expect(find.text('정답: O'), findsNothing);
    expect(
      (outline(tester, 1002)!.border! as Border).top.color,
      AppColor.danger,
    );
    expect(
      (outline(tester, 1001)!.border! as Border).top.color,
      AppColor.quizCorrectBackground,
    );
    expect(find.text('4페이지'), findsOneWidget);
    expect(tester.getRect(option), originalRect);
    expect(tester.getCenter(icon), originalRect.center);
    expect((outline(tester, 1002)!.border! as Border).top.strokeOutset, 0);
    await preview(tester, 'ox-wrong');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('OX 정답 선택은 선택한 카드에만 초록 테두리를 표시한다', (tester) async {
    await start(tester, ox: true);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('quiz_option_1001'))).dy,
      closeTo(224.75, 1),
    );
    await tester.tap(find.byKey(const ValueKey('quiz_option_1001')));
    await tester.pumpAndSettle();
    expect(
      (outline(tester, 1001)!.border! as Border).top.color,
      AppColor.success,
    );
    expect(find.text('문제 해설'), findsNothing);
    expect(find.text('다음 문제'), findsOneWidget);
    await preview(tester, 'ox-correct');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('OX의 정답이 X인 경우도 서버 보기를 기준으로 표시한다', (tester) async {
    await start(tester, ox: true, xCorrect: true);
    await tester.tap(find.byKey(const ValueKey('quiz_option_1002')));
    await tester.pumpAndSettle();
    expect(find.text('다음 문제'), findsOneWidget);
    expect(find.text('4페이지'), findsNothing);
    final selected = find.descendant(
      of: find.byKey(const ValueKey('quiz_option_1002')),
      matching: find.byType(SvgPicture),
    );
    expect(tester.widget<SvgPicture>(selected).colorFilter, isNotNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('긴 문제·보기·근거와 큰 글자도 스크롤하며 확인할 수 있다', (tester) async {
    await start(tester, width: 320, scale: 1.5, longText: true);
    final wrong = find.byKey(const ValueKey('quiz_option_1001'));
    await tester.ensureVisible(wrong);
    await tester.tap(wrong);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('다음 문제'));
    await tester.tap(find.text('다음 문제'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 10'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('페이지와 인용이 없는 문제는 페이지 배지 없이 해설을 표시한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: QuizFeedback(
            question: QuizQuestionEntity(
              questionId: 1,
              content: '문제',
              conceptName: '',
              explanation: '서버에서 받은 문제 해설',
              sourceQuote: '',
              sourcePageNo: null,
              options: [],
            ),
          ),
        ),
      ),
    );
    expect(find.text('문제 해설'), findsOneWidget);
    expect(find.text('서버에서 받은 문제 해설'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('quiz_feedback_source_badge')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('quiz_feedback_source_icon')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('완료 화면은 실제 점수·개념별 오답·인지 유형 피드백을 표시한다', (tester) async {
    await start(tester);
    final quiz = repository.quiz;
    final data = QuizResultRouteArg(
      quiz: quiz,
      materialTitle: '컴퓨터 네트워크 4주차',
      answers: [
        for (final question in quiz.questions)
          QuizAnswerEntity(
            questionId: question.questionId,
            optionId: question.options.first.optionId,
          ),
      ],
      submission: QuizSubmissionEntity(
        submissionId: 500,
        correctCount: 7,
        totalCount: 10,
        results: [
          for (var index = 0; index < 10; index++)
            QuizQuestionResultEntity(
              questionId: quiz.questions[index].questionId,
              correct: !{0, 1, 3}.contains(index),
            ),
        ],
      ),
    );
    router.go(const QuizResultRoute(7).location, extra: data);
    await tester.pumpAndSettle();
    expect(find.text('모든 문제를 풀었어요!'), findsOneWidget);
    expect(find.text('컴퓨터 네트워크 4주차'), findsOneWidget);
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('quiz_result_count_2')))
          .data,
      '3',
    );
    expect(find.text('2문제 틀렸어요'), findsOneWidget);
    expect(find.text('PDF 4~5 페이지'), findsOneWidget);
    expect(find.text('응용 문제를 많이 틀렸어요'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('응용 문제를 많이 틀렸어요')).style!.fontWeight,
      FontWeight.w600,
    );
    expect(find.byKey(const ValueKey('quiz_result_wrong_badge')), findsNothing);
    await preview(tester, 'result');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

const _quote = '"클라이언트는 SYN+ACK를 받은 뒤 ACK를 보내고, 이로써 연결이 수립된다."';

QuizEntity _quiz({
  bool ox = false,
  bool xCorrect = false,
  bool longText = false,
}) => QuizEntity(
  quizId: 7,
  materialId: 1,
  format: ox ? .ox : .multipleChoice,
  difficulty: .normal,
  questions: [
    for (var index = 0; index < 10; index++)
      QuizQuestionEntity(
        questionId: 101 + index,
        content: longText
            ? List.filled(
                4,
                '서버에게서 SYN+ACK를 받은 클라이언트는 다음에 무엇을 보내야 할까요?',
              ).join(' ')
            : ox
            ? 'UDP는 연결 과정 없이 바로 데이터를 보낸다.'
            : '서버에게서 SYN+ACK를 받은 클라이언트는 다음에 무엇을 보내야 할까요?',
        conceptName: ox
            ? 'UDP'
            : index < 3
            ? 'TCP 연결 과정'
            : index < 5
            ? '혼잡 제어'
            : index < 7
            ? 'UDP 특징'
            : index < 9
            ? '흐름 제어'
            : '연결 종료 과정',
        cognitiveType: .apply,
        explanation: '연결 수립의 마지막 단계에서 ACK를 보냅니다.',
        sourceQuote: longText ? List.filled(8, _quote).join(' ') : _quote,
        sourcePageNo: index < 2
            ? 4
            : index == 2
            ? 5
            : index < 5
            ? index + 6
            : index < 7
            ? 3
            : index < 9
            ? index
            : 6,
        options: ox
            ? [
                QuizOptionEntity(
                  optionId: 1001 + index * 10,
                  content: 'O',
                  isCorrect: !xCorrect,
                ),
                QuizOptionEntity(
                  optionId: 1002 + index * 10,
                  content: 'X',
                  isCorrect: xCorrect,
                ),
              ]
            : [
                QuizOptionEntity(
                  optionId: 1001 + index * 10,
                  content: longText
                      ? List.filled(3, '연결 요청을 위해 SYN을 전송합니다').join(' ')
                      : 'SYN',
                  isCorrect: false,
                ),
                QuizOptionEntity(
                  optionId: 1002 + index * 10,
                  content: 'ACK',
                  isCorrect: true,
                ),
                QuizOptionEntity(
                  optionId: 1003 + index * 10,
                  content: 'FIN',
                  isCorrect: false,
                ),
                QuizOptionEntity(
                  optionId: 1004 + index * 10,
                  content: 'RST',
                  isCorrect: false,
                ),
              ],
      ),
  ],
);
