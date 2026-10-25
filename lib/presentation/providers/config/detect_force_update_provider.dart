import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/app/router/router_state.dart';
import 'package:iquiz/presentation/providers/config/app_config_provier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detect_force_update_provider.g.dart';

@Riverpod(keepAlive: true)
class DetectForceUpdate extends _$DetectForceUpdate {
  @override
  void build() {
    final router = ref.watch(routerStateProvider);

    // read로 시작한 Provider는 활성 구독자가 없어 ref.listen이 중지될 수 있음
    // 앱 컨테이너에 구독을 연결해 Splash가 종료된 뒤에도 감시를 유지
    final subscription = ref.container.listen(
      appConfigProvierProvider.select(
        (config) => config.asData?.value.isUpdate,
      ),
      (prevIsUpdate, isUpdate) {
        final isNoticePage =
            router.routeInformationProvider.value.uri.path == NoticeRoute.path;

        final location = switch (isUpdate) {
          true => const NoticeRoute().location,
          false when prevIsUpdate == null || isNoticePage =>
            const HomeRoute().location,
          _ => null, // 로딩·오류 또는 이동이 필요 없는 경우 현재 화면 유지
        };

        if (location != null) router.go(location);
      },
    );
    ref.onDispose(subscription.close);
  }
}
