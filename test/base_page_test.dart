import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/app/di/learning_profile/learning_profile.dart';
import 'package:iquiz/presentation/pages/home/home_page.dart';
import 'package:iquiz/presentation/pages/splash/splash_page.dart';
import 'package:iquiz/presentation/widgets/base_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:iquiz/features/auth/repositories/entities/user_entity.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';

import 'support/quiz_fakes.dart';
import 'support/learning_profile_fakes.dart';

final _argumentProvider = Provider<String>(
  (ref) => '상위 값',
  dependencies: const [],
);

final _counterProvider = NotifierProvider<_Counter, int>(_Counter.new);

class _Counter extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

class _ProbePage extends BasePage {
  const _ProbePage({
    this.argument = '페이지 값',
    this.allowPop = true,
    this.onEvent,
    this.onCleanup,
  });

  final String argument;
  final bool allowPop;
  final void Function(String event, WidgetRef ref)? onEvent;
  final VoidCallback? onCleanup;

  @override
  Override? get argProviderOverrides =>
      _argumentProvider.overrideWithValue(argument);

  @override
  bool get canPop => allowPop;

  @override
  void onInit(WidgetRef ref) => onEvent?.call('init', ref);

  @override
  void onReady(WidgetRef ref) => onEvent?.call('ready', ref);

  @override
  void onDispose() => onCleanup?.call();

  @override
  void onResumed(WidgetRef ref) => onEvent?.call('resumed', ref);

  @override
  void onPaused(WidgetRef ref) => onEvent?.call('paused', ref);

  @override
  void onInactive(WidgetRef ref) => onEvent?.call('inactive', ref);

  @override
  void onDetached(WidgetRef ref) => onEvent?.call('detached', ref);

  @override
  void onHidden(WidgetRef ref) => onEvent?.call('hidden', ref);

  @override
  void onWillPop(WidgetRef ref) => onEvent?.call('pop', ref);

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    onEvent?.call('appBar', ref);
    return AppBar(title: Text('제목 ${ref.watch(_argumentProvider)}'));
  }

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    onEvent?.call('body', ref);
    return Text('본문 ${ref.watch(_argumentProvider)}');
  }

  @override
  Widget? buildBottomSheet(BuildContext context, WidgetRef ref) {
    onEvent?.call('bottomSheet', ref);
    return null;
  }
}

Widget _host(Widget page, {GlobalKey<NavigatorState>? navigatorKey}) {
  return ProviderScope(
    overrides: [
      userAuthProvider.overrideWith(_PageTestAuth.new),
      quizRepositoryProvider.overrideWithValue(FakeQuizRepository()),
      learningProfileRepositoryProvider.overrideWithValue(
        FakeLearningProfileRepository(),
      ),
    ],
    child: MaterialApp(navigatorKey: navigatorKey, home: page),
  );
}

void main() {
  testWidgets('초기화, 준비, 화면, 앱 상태, 뒤로가기는 페이지 override를 읽는다', (tester) async {
    final values = <String, String>{};
    final order = <String>[];
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      _host(
        _ProbePage(
          allowPop: false,
          onEvent: (event, ref) {
            values[event] = ref.read(_argumentProvider);
            order.add(event);
          },
        ),
        navigatorKey: navigatorKey,
      ),
    );

    expect(order.first, 'init');
    expect(order.indexOf('ready'), greaterThan(order.indexOf('body')));

    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.detached,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await navigatorKey.currentState!.maybePop();

    expect(values, {
      for (final event in [
        'init',
        'ready',
        'appBar',
        'body',
        'bottomSheet',
        'inactive',
        'hidden',
        'paused',
        'detached',
        'resumed',
        'pop',
      ])
        event: '페이지 값',
    });
    expect(find.byType(_ProbePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('두 페이지의 인자는 분리되고 상위 Provider 값도 유지된다', (tester) async {
    final initializedArguments = <String>[];

    await tester.pumpWidget(
      _host(
        Column(
          children: [
            Consumer(
              builder: (context, ref, child) =>
                  Text('상위 ${ref.watch(_argumentProvider)}'),
            ),
            Expanded(
              child: Row(
                children: [
                  for (final argument in ['첫 번째', '두 번째'])
                    Expanded(
                      child: _ProbePage(
                        argument: argument,
                        onEvent: (event, ref) {
                          if (event == 'init') {
                            initializedArguments.add(
                              ref.read(_argumentProvider),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    expect(initializedArguments, ['첫 번째', '두 번째']);
    expect(find.text('본문 첫 번째'), findsOneWidget);
    expect(find.text('본문 두 번째'), findsOneWidget);
    expect(find.text('상위 상위 값'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('재빌드해도 초기화와 준비는 한 번, 제거 시 정리는 한 번 실행된다', (tester) async {
    final calls = <String, int>{};
    var cleanupCalls = 0;

    _ProbePage page() => _ProbePage(
      onEvent: (event, ref) =>
          calls.update(event, (count) => count + 1, ifAbsent: () => 1),
      onCleanup: () => cleanupCalls++,
    );

    await tester.pumpWidget(_host(page()));
    await tester.pumpWidget(_host(page()));
    await tester.pump();

    expect(calls['body'], greaterThan(1));
    expect(calls['init'], 1);
    expect(calls['ready'], 1);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(cleanupCalls, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    expect(calls['inactive'], isNull);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(tester.takeException(), isNull);
  });

  testWidgets('onReady에서는 이미 구독 중인 상태를 변경할 수 있다', (tester) async {
    await tester.pumpWidget(
      _host(
        Column(
          children: [
            Consumer(
              builder: (context, ref, child) =>
                  Text('카운트 ${ref.watch(_counterProvider)}'),
            ),
            Expanded(
              child: _ProbePage(
                onEvent: (event, ref) {
                  if (event == 'ready') {
                    ref.read(_counterProvider.notifier).increment();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.text('카운트 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('첫 프레임 전에 제거되면 onReady를 실행하지 않는다', (tester) async {
    var initCalls = 0;
    var readyCalls = 0;
    var cleanupCalls = 0;
    final binding = tester.binding;

    // 첫 프레임 완료 없이 위젯만 구성해 예약된 콜백 유지
    binding.attachRootWidget(
      binding.wrapWithDefaultView(
        _host(
          _ProbePage(
            onEvent: (event, ref) {
              if (event == 'init') initCalls++;
              if (event == 'ready') readyCalls++;
            },
            onCleanup: () => cleanupCalls++,
          ),
        ),
      ),
    );
    binding.buildOwner!.buildScope(binding.rootElement!);
    expect(initCalls, 1);
    expect(readyCalls, 0);

    binding.attachRootWidget(
      binding.wrapWithDefaultView(const SizedBox.shrink()),
    );
    binding.buildOwner!.buildScope(binding.rootElement!);
    binding.buildOwner!.finalizeTree();
    await tester.pump();

    expect(cleanupCalls, 1);
    expect(readyCalls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('허용된 뒤로가기에서는 onWillPop을 호출하지 않는다', (tester) async {
    var blockedPopCalls = 0;
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      _host(const Scaffold(), navigatorKey: navigatorKey),
    );
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (context) => _ProbePage(
          onEvent: (event, ref) {
            if (event == 'pop') blockedPopCalls++;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await navigatorKey.currentState!.maybePop();
    await tester.pumpAndSettle();

    expect(find.byType(_ProbePage), findsNothing);
    expect(blockedPopCalls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('기존 HomePage와 SplashPage도 정상적으로 렌더링된다', (tester) async {
    await tester.pumpWidget(_host(const HomePage()));
    expect(find.text('최근 자료'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(_host(const _PageTestSplash()));
    expect(find.byType(Scaffold), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _PageTestAuth extends UserAuth {
  @override
  UserAuthState build() => const UserAuthState(
    AuthStatus.authenticated,
    user: UserEntity(id: 1, email: 'test@example.com', nickname: '테스트'),
  );
}

class _PageTestSplash extends SplashPage {
  const _PageTestSplash();
  @override
  void onReady(WidgetRef ref) {}
}
