import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/presentation/pages/splash/providers/splash_animation.dart';
import 'package:iquiz/presentation/providers/config/app_config_provier.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router_state.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

@Riverpod(keepAlive: true)
class RouterState extends _$RouterState {
  @override
  GoRouter build() {
    Uri? pendingLocation;
    final router = GoRouter(
      debugLogDiagnostics: true,
      navigatorKey: rootNavigatorKey,
      initialLocation: SplashRoute.path,
      routes: $appRoutes,
      redirect: (context, route) {
        final path = route.uri.path;

        // 설정과 인증이 먼저 준비돼도 스플래시의 첫 재생이 끝날 때까지 대기
        if (!ref.read(splashAnimationProvider)) {
          if (path != SplashRoute.path) pendingLocation = route.uri;
          return path == SplashRoute.path ? null : SplashRoute.path;
        }

        // 대기 중 요청한 보호 경로도 이후의 인증·업데이트 검사를 거쳐 이동
        if (path == SplashRoute.path && pendingLocation != null) {
          final destination = pendingLocation!;
          pendingLocation = null;
          return destination.toString();
        }

        final requiresUpdate =
            ref.read(appConfigProvierProvider).asData?.value.isUpdate == true;
        if (requiresUpdate) {
          return path == NoticeRoute.path ? null : NoticeRoute.path;
        }

        return _authenticationRedirect(
          route.uri,
          ref.read(userAuthProvider).status,
        );
      },
    );

    ref.listen(userAuthProvider, (_, _) => router.refresh());
    ref.listen(appConfigProvierProvider, (_, _) => router.refresh());
    ref.listen(splashAnimationProvider, (_, _) => router.refresh());
    ref.onDispose(router.dispose);

    return router;
  }

  String? _authenticationRedirect(Uri location, AuthStatus status) {
    final path = location.path;
    const authPaths = {SignInRoute.path, SignUpRoute.path};
    const entryPaths = {...authPaths, SplashRoute.path, NoticeRoute.path};

    return switch (status) {
      AuthStatus.initializing ||
      AuthStatus.failure => path == SplashRoute.path ? null : SplashRoute.path,
      AuthStatus.unauthenticated when authPaths.contains(path) => null,
      AuthStatus.unauthenticated => SignInRoute(
        from: path == UploadRoute.path ? path : null,
      ).location,
      // 앱 내부 보호 경로만 허용
      AuthStatus.authenticated when entryPaths.contains(path) =>
        location.queryParameters['from'] == UploadRoute.path
            ? UploadRoute.path
            : HomeRoute.path,
      AuthStatus.authenticated => null,
    };
  }
}
