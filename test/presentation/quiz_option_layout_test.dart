import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iquiz/app/style/app_theme.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_question_entity.dart';
import 'package:iquiz/presentation/pages/quiz/widgets/quiz_question_content.dart';

void main() {
  setUpAll(() async {
    await (FontLoader('pretendard')
          ..addFont(
            rootBundle.load('assets/fonts/pretendard/Pretendard-Regular.otf'),
          )
          ..addFont(
            rootBundle.load('assets/fonts/pretendard/Pretendard-Medium.otf'),
          ))
        .load();
  });

  for (final width in [320.0, 384.0]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets('객관식 $width 폭·$scale 배율은 정답·오답·굵기 변화에도 모든 보기의 크기와 위치가 같다', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final selected = ValueNotifier<int?>(null);
        addTearDown(selected.dispose);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 2400),
                  textScaler: TextScaler.linear(scale),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ValueListenableBuilder<int?>(
                    valueListenable: selected,
                    builder: (context, value, _) => QuizQuestionContent(
                      question: _question,
                      format: .multipleChoice,
                      selected: value,
                      checked: value != null,
                      onSelect: (id) => selected.value = id,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final before = {
          for (final option in _question.options)
            option.optionId: tester.getRect(
              find.byKey(ValueKey('quiz_option_${option.optionId}')),
            ),
        };
        expect(
          before[1001]!.top -
              tester.getBottomLeft(find.text(_question.content)).dy,
          31,
        );
        for (final answer in [1001, 1002, null]) {
          selected.value = answer;
          await tester.pumpAndSettle();
          for (final option in _question.options) {
            expect(
              tester.getRect(
                find.byKey(ValueKey('quiz_option_${option.optionId}')),
              ),
              before[option.optionId],
              reason: '선택 $answer / 보기 ${option.optionId}',
            );
            expect(find.text(option.content), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}

const _question = QuizQuestionEntity(
  questionId: 101,
  content: '서버에게 SYN+ACK를 받은 클라이언트는 무엇을 보내야 할까요?',
  conceptName: 'TCP 연결 과정',
  explanation: 'ACK를 보내 연결을 수립합니다.',
  sourceQuote: '',
  sourcePageNo: null,
  options: [
    .new(optionId: 1001, content: 'ACK', isCorrect: true),
    .new(
      optionId: 1002,
      content: '서버에게 SYN 연결 요청을 보내고 응답을 기다립니다.',
      isCorrect: false,
    ),
    .new(
      optionId: 1003,
      content: '연결 종료를 위한 FIN 메시지를 보냅니다. Connection termination request',
      isCorrect: false,
    ),
    .new(optionId: 1004, content: '동일한 SYN+ACK를 다시 전송합니다.', isCorrect: false),
  ],
);
