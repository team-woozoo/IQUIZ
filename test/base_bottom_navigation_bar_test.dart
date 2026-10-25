import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iquiz/core/services/app_size.dart';
import 'package:iquiz/presentation/widgets/button/base_bottom_navigation_bar.dart';

void main() {
  testWidgets('기본색과 지정한 배경색 모두 하단 버튼을 오류 없이 렌더링한다', (tester) async {
    for (final color in <Color?>[null, Colors.blue]) {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            AppSize.init(context);
            return child!;
          },
          home: Scaffold(
            bottomNavigationBar: BaseBottomNavigationBar.singleBtn(
              btnText: '업데이트',
              onBtnClicked: null,
              backgroundColor: color,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('업데이트'), findsOneWidget);
    }
  });

  testWidgets('두 버튼 팩토리는 각 동작과 비활성 상태를 독립적으로 처리한다', (tester) async {
    var primaryTaps = 0;
    var secondaryTaps = 0;
    Future<void> show({bool secondaryEnabled = true}) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            AppSize.init(context);
            return child!;
          },
          home: Scaffold(
            bottomNavigationBar: BaseBottomNavigationBar.dividedBtn(
              rightBtnText: '문제 생성',
              leftBtnText: '기존 문제',
              onRightBtnClicked: () => primaryTaps++,
              onLeftBtnClicked: secondaryEnabled ? () => secondaryTaps++ : null,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> tap(String title) async {
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
    }

    await show();
    await tap('기존 문제');
    await tap('문제 생성');
    expect(secondaryTaps, 1);
    expect(primaryTaps, 1);

    await show(secondaryEnabled: false);
    await tap('기존 문제');
    await tap('문제 생성');
    expect(secondaryTaps, 1);
    expect(primaryTaps, 2);
    expect(tester.takeException(), isNull);
  });
}
