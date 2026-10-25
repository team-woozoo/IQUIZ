import 'package:iquiz/app/di/config/config.dart';
import 'package:iquiz/features/config/repositories/entities/config_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config_provier.g.dart';

@Riverpod(keepAlive: true)
class AppConfigProvier extends _$AppConfigProvier {
  @override
  Stream<ConfigEntity> build() async* {
    final repository = ref.watch(configRepositoryProvider);

    // 앱 시작 시 한번 초기화
    final initialConfig = await repository.getConfig();
    if (!ref.mounted) return;

    yield initialConfig.fold(
      onSuccess: (config) => config,
      onFailure: (error) => throw error,
    );

    // Config 값 구독
    yield* repository.watchConfig().map(
      (result) => result.fold(
        onSuccess: (config) => config,
        onFailure: (error) => throw error,
      ),
    );
  }
}
