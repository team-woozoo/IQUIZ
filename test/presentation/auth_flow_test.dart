import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/di/auth/auth.dart';
import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/app/di/learning_profile/learning_profile.dart';
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/app/router/router_state.dart';
import 'package:iquiz/app/style/app_theme.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/core/services/app_size.dart';
import 'package:iquiz/features/auth/repositories/auth_repository.dart';
import 'package:iquiz/features/auth/repositories/entities/user_entity.dart';
import 'package:iquiz/features/auth/services/auth_token_manager.dart';
import 'package:iquiz/features/config/repositories/enums/config_platform.enum.dart';
import 'package:iquiz/features/config/repositories/entities/config_entity.dart';
import 'package:iquiz/presentation/pages/home/home_page.dart';
import 'package:iquiz/presentation/pages/sign_in/sign_in_page.dart';
import 'package:iquiz/presentation/pages/sign_up/sign_up_page.dart';
import 'package:iquiz/presentation/pages/splash/splash_page.dart';
import 'package:iquiz/presentation/providers/config/app_config_provier.dart';
import 'package:iquiz/presentation/pages/splash/providers/splash_animation.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';
import 'package:lottie/lottie.dart';

import '../support/auth_fakes.dart';
import '../support/quiz_fakes.dart';
import '../support/learning_profile_fakes.dart';

const _user = UserEntity(id: 42, email: 'quiz@example.com', nickname: '퀴즈');

void main() {
  late AuthTokenManager manager;
  late _Repository repository;
  late FakeQuizRepository quizRepository;
  late ProviderContainer container;

  setUpAll(() async {
    await AssetLottie('assets/lottie/iquiz_splash.json').load();
    await (FontLoader('pretendard')..addFont(
          rootBundle.load('assets/fonts/pretendard/Pretendard-Regular.otf'),
        ))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  setUp(() {
    manager = AuthTokenManager(
      local: MemoryAuthStorage(),
      remote: FakeAuthRemote(),
    );
    repository = _Repository(manager);
    quizRepository = FakeQuizRepository();
    container = ProviderContainer(
      overrides: [
        authTokenManagerProvider.overrideWithValue(manager),
        authRepositoryProvider.overrideWithValue(repository),
        quizRepositoryProvider.overrideWithValue(quizRepository),
        learningProfileRepositoryProvider.overrideWithValue(
          FakeLearningProfileRepository(),
        ),
        appConfigProvierProvider.overrideWith(_Config.new),
      ],
    );
  });
  tearDown(() {
    container.dispose();
    manager.dispose();
  });

  test('인증 복원 실패를 비로그인과 구분하고 세션 종료 이벤트를 반영한다', () async {
    repository.restoreError = Exception('offline');
    final notifier = container.read(userAuthProvider.notifier);
    await notifier.initialize();
    expect(container.read(userAuthProvider).status, AuthStatus.failure);
    repository.restoreError = null;
    repository.restoredUser = _user;
    await notifier.initialize();
    expect(container.read(userAuthProvider).user?.id, 42);
    await manager.clear();
    expect(container.read(userAuthProvider).status, AuthStatus.unauthenticated);
  });

  test('로그아웃 후 늦게 완료된 로그인 결과가 인증 상태를 되살리지 않는다', () async {
    final pending = Completer<Result<UserEntity>>();
    repository.signInResult = pending.future;
    final notifier = container.read(userAuthProvider.notifier);
    final login = notifier.signIn(email: 'quiz@example.com', password: 'pw');
    await notifier.signOut();
    pending.complete(Result.success(_user));
    await login;
    expect(container.read(userAuthProvider).status, AuthStatus.unauthenticated);
  });

  for (final scenario in [
    (signedIn: false, reduceMotion: false),
    (signedIn: true, reduceMotion: false),
    (signedIn: false, reduceMotion: true),
  ]) {
    final signedIn = scenario.signedIn;
    testWidgets(
      '초기화가 빨라도 Lottie 한 번 재생 후 ${signedIn ? '홈' : '로그인'}으로 이동한다${scenario.reduceMotion ? ' (애니메이션 줄이기 활성)' : ''}',
      (tester) async {
        if (scenario.reduceMotion) {
          tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
              const FakeAccessibilityFeatures(disableAnimations: true);
          addTearDown(
            tester
                .binding
                .platformDispatcher
                .clearAccessibilityFeaturesTestValue,
          );
        }
        repository.restoredUser = signedIn ? _user : null;
        final router = container.read(routerStateProvider);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const _TestApp(),
          ),
        );
        await tester.pump();
        await tester.pump();
        final controller =
            tester.widget<LottieBuilder>(find.byType(LottieBuilder)).controller!
                as AnimationController;
        final duration = controller.duration!;
        expect(repository.restoreCount, 1);
        expect(
          container.read(userAuthProvider).status,
          signedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated,
        );

        await tester.pump(duration - const Duration(milliseconds: 1));
        expect(
          router.routeInformationProvider.value.uri.path,
          SplashRoute.path,
        );
        expect(container.read(splashAnimationProvider), isFalse);

        await tester.pump(const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
        expect(container.read(splashAnimationProvider), isTrue);
        expect(
          router.routeInformationProvider.value.uri.path,
          signedIn ? HomeRoute.path : SignInRoute.path,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets('인증 복원이 느리면 애니메이션 완료 후에도 Splash를 유지한다', (tester) async {
    final pending = Completer<Result<UserEntity?>>();
    repository.restoreResult = pending.future;
    final router = container.read(routerStateProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const _TestApp()),
    );
    await tester.pumpAndSettle();
    expect(container.read(splashAnimationProvider), isTrue);
    expect(container.read(userAuthProvider).status, AuthStatus.initializing);
    expect(router.routeInformationProvider.value.uri.path, SplashRoute.path);
    expect(find.byType(SplashPage), findsOneWidget);
    expect(
      tester
          .widget<LottieBuilder>(find.byType(LottieBuilder))
          .controller!
          .value,
      1,
    );

    pending.complete(Result.success(_user));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, HomeRoute.path);
    expect(find.byType(HomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('설정 로딩이 느리면 애니메이션과 병렬로 기다린다', (tester) async {
    final pending = Completer<void>();
    container.updateOverrides([
      authTokenManagerProvider.overrideWithValue(manager),
      authRepositoryProvider.overrideWithValue(repository),
      quizRepositoryProvider.overrideWithValue(quizRepository),
      learningProfileRepositoryProvider.overrideWithValue(
        FakeLearningProfileRepository(),
      ),
      appConfigProvierProvider.overrideWith(
        () => _Config(initialization: pending.future),
      ),
    ]);
    final router = container.read(routerStateProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const _TestApp()),
    );
    await tester.pumpAndSettle();
    expect(container.read(splashAnimationProvider), isTrue);
    expect(router.routeInformationProvider.value.uri.path, SplashRoute.path);
    expect(repository.restoreCount, 0);

    final completedAt = tester.binding.clock.now();
    pending.complete();
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, SignInRoute.path);
    expect(
      tester.binding.clock.now().difference(completedAt),
      lessThan(const Duration(seconds: 1)),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('강제 업데이트 설정도 첫 애니메이션이 끝난 뒤 공지로 이동한다', (tester) async {
    container.updateOverrides([
      authTokenManagerProvider.overrideWithValue(manager),
      authRepositoryProvider.overrideWithValue(repository),
      quizRepositoryProvider.overrideWithValue(quizRepository),
      learningProfileRepositoryProvider.overrideWithValue(
        FakeLearningProfileRepository(),
      ),
      appConfigProvierProvider.overrideWith(
        () => _Config(requiresUpdate: true),
      ),
    ]);
    final router = container.read(routerStateProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const _TestApp()),
    );
    await tester.pump();
    await tester.pump();
    expect(
      container.read(appConfigProvierProvider).requireValue.isUpdate,
      isTrue,
    );
    expect(router.routeInformationProvider.value.uri.path, SplashRoute.path);

    await tester.pumpAndSettle();
    expect(container.read(splashAnimationProvider), isTrue);
    expect(router.routeInformationProvider.value.uri.path, NoticeRoute.path);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('초기화 실패 화면은 첫 애니메이션 완료 후 표시한다', (tester) async {
    repository.restoreError = Exception('offline');
    final router = container.read(routerStateProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const _TestApp()),
    );
    await tester.pump();
    await tester.pump();
    expect(container.read(userAuthProvider).status, AuthStatus.failure);
    expect(find.byType(LottieBuilder), findsOneWidget);
    expect(find.text('다시 시도'), findsNothing);

    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, SplashRoute.path);
    expect(find.text('다시 시도'), findsOneWidget);
    await tester.tap(find.text('다시 로그인'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, SignInRoute.path);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('로그인 검증·중복 방지·홈 이동·프로필 진입과 로그아웃을 처리한다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await container.read(userAuthProvider.notifier).initialize();
    final router = container.read(routerStateProvider);
    final boundary = GlobalKey<State<StatefulWidget>>();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(key: boundary, child: const _TestApp()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SignInPage), findsOneWidget);
    await _preview(tester, boundary, 'sign-in');
    await tester.tap(find.widgetWithText(FilledButton, '로그인'));
    await tester.pumpAndSettle();
    expect(find.text('이메일을 입력해 주세요.'), findsOneWidget);
    expect(repository.signInCount, 0);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'quiz@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    final pending = Completer<Result<UserEntity>>();
    repository.signInResult = pending.future;
    await tester.tap(find.widgetWithText(FilledButton, '로그인'));
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(repository.signInCount, 1);
    expect(router.routeInformationProvider.value.uri.path, SignInRoute.path);
    pending.complete(Result.success(_user));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, HomeRoute.path);
    expect(find.byType(HomePage), findsOneWidget);
    await tester.tap(find.text('프로필'));
    await tester.pumpAndSettle();
    expect(find.text('나의 학습 분석'), findsOneWidget);
    expect(find.text('로그아웃'), findsOneWidget);
    await tester.tap(find.text('로그아웃'));
    await tester.pumpAndSettle();
    expect(find.byType(SignInPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('회원가입 비밀번호 확인 및 중복 이메일 오류를 표시하고 가입 후 이메일을 채운다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await container.read(userAuthProvider.notifier).initialize();
    final boundary = GlobalKey<State<StatefulWidget>>();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(key: boundary, child: const _TestApp()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('회원가입'));
    await tester.pumpAndSettle();
    expect(find.byType(SignUpPage), findsOneWidget);
    await _preview(tester, boundary, 'sign-up');
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '퀴즈');
    await tester.enterText(fields.at(1), 'quiz@example.com');
    await tester.enterText(fields.at(2), 'password');
    await tester.enterText(fields.at(3), 'different');
    final submit = find.widgetWithText(FilledButton, '가입하기');
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    expect(find.text('비밀번호가 서로 달라요'), findsOneWidget);
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
    expect(repository.signUpCount, 0);
    await tester.enterText(fields.at(3), 'password');
    await tester.pumpAndSettle();
    repository.signupError = const EmailAlreadyExistsException();
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('이미 가입된 이메일입니다.'), findsOneWidget);
    repository.signupError = null;
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.byType(SignInPage), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller
          ?.text,
      'quiz@example.com',
    );
    expect(container.read(userAuthProvider).status, AuthStatus.unauthenticated);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('보호된 업로드 경로 접근은 로그인으로 보내고 로그인 후 돌아온다', (tester) async {
    await container.read(userAuthProvider.notifier).initialize();
    final router = container.read(routerStateProvider);
    router.go(UploadRoute.path);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const _TestApp()),
    );
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, SignInRoute.path);
    expect(
      router.routeInformationProvider.value.uri.queryParameters['from'],
      UploadRoute.path,
    );
    await container
        .read(userAuthProvider.notifier)
        .signIn(email: 'quiz@example.com', password: 'pw');
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, UploadRoute.path);
    await tester.pumpWidget(const SizedBox());
  });
}

Future<void> _preview(WidgetTester tester, GlobalKey key, String name) async {
  if (!const bool.fromEnvironment('AUTH_PREVIEWS')) return;
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('/private/tmp/iquiz-$name.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

class _Repository implements AuthRepository {
  _Repository(this.manager);
  final AuthTokenManager manager;
  int signInCount = 0;
  int signUpCount = 0;
  int restoreCount = 0;
  Exception? restoreError;
  Exception? signupError;
  UserEntity? restoredUser;
  Future<Result<UserEntity>>? signInResult;
  Future<Result<UserEntity?>>? restoreResult;

  @override
  Future<Result<UserEntity?>> restore() async {
    restoreCount++;
    if (restoreResult != null) return await restoreResult!;
    return restoreError != null
        ? Result.failure(restoreError!)
        : Result.success(restoredUser);
  }

  @override
  Future<Result<UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    signInCount++;
    return signInResult == null ? Result.success(_user) : await signInResult!;
  }

  @override
  Future<Result<int>> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    signUpCount++;
    return signupError != null
        ? Result.failure(signupError!)
        : Result.success(42);
  }

  @override
  Future<Result<void>> signOut() async {
    await manager.clear();
    return Result.success(null);
  }
}

class _Config extends AppConfigProvier {
  _Config({this.requiresUpdate = false, this.initialization});

  final bool requiresUpdate;
  final Future<void>? initialization;

  @override
  Stream<ConfigEntity> build() async* {
    if (initialization != null) await initialization;
    yield ConfigEntity(
      baseUrl: 'https://example.test',
      enabled: true,
      minBuildNumber: requiresUpdate ? 2 : 0,
      noticeUrl: Uri.parse('https://example.test/update'),
      title: '',
      description: '',
      details: const [],
      version: '1.0.0',
      buildNumber: 1,
      platform: ConfigPlatform.android,
      minVersion: '1.0.0',
    );
  }
}

class _TestApp extends ConsumerWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(routerStateProvider),
      builder: (context, child) {
        AppSize.init(context);
        return child!;
      },
    );
  }
}
