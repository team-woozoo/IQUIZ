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
import 'package:iquiz/app/di/auth/auth.dart';
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/app/style/app_theme.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/auth/repositories/auth_repository.dart';
import 'package:iquiz/features/auth/repositories/entities/user_entity.dart';
import 'package:iquiz/presentation/pages/sign_in/sign_in_page.dart';
import 'package:iquiz/presentation/pages/sign_up/sign_up_page.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';

void main() {
  late GoRouter router;
  late ProviderContainer container;
  late _Repository repository;
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
  });

  Future<void> start(
    WidgetTester tester, {
    bool signup = false,
    double width = 384,
    double scale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 832);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    repository = _Repository();
    container = ProviderContainer(
      overrides: [
        userAuthProvider.overrideWith(_Auth.new),
        authRepositoryProvider.overrideWithValue(repository),
      ],
    );
    router = GoRouter(
      initialLocation: signup ? '/sign-up' : '/sign-in',
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

  Future<void> fillSignup(
    WidgetTester tester, {
    String confirmation = 'password1',
  }) async {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '테스트계정');
    await tester.enterText(fields.at(1), 'hong@school.ac.kr');
    await tester.enterText(fields.at(2), 'password1');
    await tester.enterText(fields.at(3), confirmation);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }

  Future<void> preview(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('AUTH_PREVIEWS')) return;
    final positions = [
      for (final label in [
        '닉네임',
        '이메일',
        '비밀번호',
        '비밀번호 확인',
        '사용할 수 있는 닉네임이에요',
        '사용할 수 있는 이메일이에요',
        '8자 이상, 영문과 숫자를 섞어 만들었어요',
        '비밀번호가 서로 달라요',
      ])
        if (find.text(label).evaluate().isNotEmpty)
          '$label: ${tester.getRect(find.text(label))}',
    ];
    await tester.runAsync(() async {
      await File('/private/tmp/iquiz-auth-$name-layout.txt')
          .writeAsString(positions.join('\n'));
      final render =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await render.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('/private/tmp/iquiz-auth-$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets('로그인 로고·폼·버튼을 Figma의 위치와 크기로 렌더링한다', (tester) async {
    await start(tester);
    final logo = find.byWidgetPredicate(
      (w) => w is SvgPicture && w.semanticsLabel == '아이퀴즈',
    );
    expect(tester.getSize(logo), const Size(177, 70));
    expect(tester.getTopLeft(logo), const Offset(103.5, 108));
    expect(tester.getTopLeft(find.text('이메일')).dx, 16);
    expect(tester.getTopLeft(find.text('이메일')).dy, closeTo(209, 1));
    final button = find.widgetWithText(FilledButton, '로그인');
    expect(tester.getSize(button).width, 352);
    expect(tester.getSize(button).height, closeTo(52, 1));
    expect(find.text('아직 계정이 없으신가요?'), findsOneWidget);
    expect(find.byTooltip('비밀번호 표시'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await preview(tester, 'sign-in');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('입력 지우기와 비밀번호 표시를 동작시키고 회원가입에서 돌아온다', (tester) async {
    await start(tester);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, 'quiz@example.com');
    await tester.enterText(fields.last, 'password1');
    expect(
      tester.widget<TextField>(find.byType(TextField).last).obscureText,
      isTrue,
    );
    await tester.tap(find.byTooltip('비밀번호 표시'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).last).obscureText,
      isFalse,
    );
    await tester.tap(find.byTooltip('이메일 지우기'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(fields.first).controller!.text,
      isEmpty,
    );
    await tester.tap(find.text('회원가입'));
    await tester.pumpAndSettle();
    expect(find.byType(SignUpPage), findsOneWidget);
    await tester.tap(find.byTooltip('로그인으로 돌아가기'));
    await tester.pumpAndSettle();
    expect(find.byType(SignInPage), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('닉네임부터 입력하고 모든 항목이 유효하면 하단 가입 버튼을 활성화한다', (tester) async {
    await start(tester, signup: true);
    final button = find.widgetWithText(FilledButton, '가입하기');
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    expect(tester.getTopLeft(find.text('닉네임')), const Offset(16, 108));
    await fillSignup(tester);
    expect(find.text('사용할 수 있는 닉네임이에요'), findsOneWidget);
    expect(find.text('사용할 수 있는 이메일이에요'), findsOneWidget);
    expect(find.text('8자 이상, 영문과 숫자를 섞어 만들었어요'), findsOneWidget);
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
    expect(tester.getTopLeft(button).dx, 20);
    expect(tester.getBottomRight(button).dy, closeTo(784, 1));
    await preview(tester, 'sign-up-valid');
    final pending = Completer<Result<int>>();
    repository.pending = pending.future;
    await tester.tap(button);
    await tester.pump();
    expect(repository.signUps, 1);
    expect(repository.nickname, '테스트계정');
    expect(repository.email, 'hong@school.ac.kr');
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    pending.complete(Result.success(42));
    await tester.pumpAndSettle();
    expect(find.byType(SignInPage), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      'hong@school.ac.kr',
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('비밀번호 불일치와 원본 변경을 즉시 반영해 가입을 차단한다', (tester) async {
    await start(tester, signup: true);
    await fillSignup(tester, confirmation: 'hong@school');
    final button = find.widgetWithText(FilledButton, '가입하기');
    expect(find.text('비밀번호가 서로 달라요'), findsOneWidget);
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    await tester.tap(find.byTooltip('비밀번호 표시').last);
    await tester.pumpAndSettle();
    await preview(tester, 'sign-up-error');
    await tester.enterText(find.byType(TextFormField).at(3), 'password1');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
    await tester.enterText(find.byType(TextFormField).at(2), 'changed123');
    await tester.pumpAndSettle();
    expect(find.text('비밀번호가 서로 달라요'), findsOneWidget);
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    expect(repository.signUps, 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('서버 필드 오류를 표시하고 수정 시 오래된 오류를 지운다', (tester) async {
    await start(tester, signup: true);
    await fillSignup(tester);
    repository.error = const EmailAlreadyExistsException();
    await tester.tap(find.text('가입하기'));
    await tester.pumpAndSettle();
    expect(find.text('이미 가입된 이메일입니다.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(1), 'new@example.com');
    await tester.pumpAndSettle();
    expect(find.text('이미 가입된 이메일입니다.'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('좁은 화면·큰 글씨·키보드에서도 확인란과 가입 버튼에 접근한다', (tester) async {
    await start(tester, signup: true, width: 320, scale: 1.5);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await fillSignup(tester);
    await tester.ensureVisible(find.byType(TextFormField).last);
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.widgetWithText(FilledButton, '가입하기')).bottom,
      lessThanOrEqualTo(532),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

class _Auth extends UserAuth {
  @override
  UserAuthState build() => const UserAuthState(AuthStatus.unauthenticated);
}

class _Repository implements AuthRepository {
  int signUps = 0;
  String? nickname;
  String? email;
  Exception? error;
  Future<Result<int>>? pending;

  @override
  Future<Result<int>> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    signUps++;
    this.nickname = nickname;
    this.email = email;
    if (pending != null) return await pending!;
    return error == null ? Result.success(42) : Result.failure(error!);
  }

  @override
  Future<Result<UserEntity?>> restore() async => Result.success(null);
  @override
  Future<Result<UserEntity>> signIn({
    required String email,
    required String password,
  }) => throw UnimplementedError();
  @override
  Future<Result<void>> signOut() async => Result.success(null);
}
