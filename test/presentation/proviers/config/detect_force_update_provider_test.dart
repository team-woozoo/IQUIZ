import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/di/config/config.dart';
import 'package:iquiz/app/router/router_state.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/config/repositories/enums/config_platform.enum.dart';
import 'package:iquiz/features/config/repositories/config_repository.dart';
import 'package:iquiz/features/config/repositories/entities/config_entity.dart';
import 'package:iquiz/presentation/pages/splash/splash_page.dart';

void main() {
  for (final requiresUpdate in [false, true]) {
    testWidgets(
      '초기화 후 ${requiresUpdate ? '공지' : '홈'} 화면으로 이동하고 Splash 종료 후에도 감시한다',
      (tester) async {
        final initialization = Completer<void>();
        final repository = _Repository();
        final router = GoRouter(
          initialLocation: '/splash',
          routes: [
            GoRoute(
              path: '/splash',
              builder: (_, _) => _Splash(initialization.future),
            ),
            for (final path in ['/home', '/notice', '/quiz'])
              GoRoute(path: path, builder: (_, _) => const SizedBox()),
          ],
        );
        final container = ProviderContainer(
          overrides: [
            configRepositoryProvider.overrideWithValue(repository),
            routerStateProvider.overrideWithValue(router),
          ],
        );
        var disposed = false;
        addTearDown(() async {
          if (!disposed) container.dispose();
          router.dispose();
          await repository.updates.close();
        });
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(routerConfig: router),
          ),
        );
        await tester.pump();
        expect(repository.fetchCount, 0);
        expect(router.routeInformationProvider.value.uri.path, '/splash');

        initialization.complete();
        await tester.pump();
        await tester.pump();
        expect(repository.fetchCount, 1);
        expect(router.routeInformationProvider.value.uri.path, '/splash');

        repository.initial.complete(Result.success(_config(requiresUpdate)));
        await tester.pump();
        await tester.pump();
        expect(
          router.routeInformationProvider.value.uri.path,
          requiresUpdate ? '/notice' : '/home',
        );
        await tester.pump(const Duration(seconds: 1));

        repository.updates.add(Result.success(_config(!requiresUpdate)));
        await tester.pump();
        await tester.pump();
        expect(
          router.routeInformationProvider.value.uri.path,
          requiresUpdate ? '/home' : '/notice',
        );

        repository.updates.add(Result.success(_config(false)));
        await tester.pump();
        await tester.pump();
        router.go('/quiz');
        await tester.pump();
        repository.updates.add(Result.success(_config(false)));
        await tester.pump();
        expect(router.routeInformationProvider.value.uri.path, '/quiz');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        container.dispose();
        disposed = true;
        expect(repository.updates.hasListener, isFalse);
      },
    );
  }
}

class _Splash extends SplashPage {
  const _Splash(this.initialization);

  final Future<void> initialization;

  @override
  Future<void> initData(WidgetRef ref) => initialization;

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) => const SizedBox();
}

class _Repository implements ConfigRepository {
  final initial = Completer<Result<ConfigEntity>>();
  final updates = StreamController<Result<ConfigEntity>>.broadcast();
  int fetchCount = 0;

  @override
  Future<Result<ConfigEntity>> getConfig() {
    fetchCount++;
    return initial.future;
  }

  @override
  Stream<Result<ConfigEntity>> watchConfig() => updates.stream;
}

ConfigEntity _config(bool requiresUpdate) => ConfigEntity(
  baseUrl: '',
  enabled: true,
  minBuildNumber: requiresUpdate ? 2 : 0,
  noticeUrl: Uri.parse('https://example.com'),
  title: '',
  description: '',
  details: const [],
  version: '1.0.0',
  buildNumber: 1,
  platform: ConfigPlatform.android,
  minVersion: '1.0.0',
);
