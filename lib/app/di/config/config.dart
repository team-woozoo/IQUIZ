import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/features/config/data_source/local/config_local_data_source.dart';
import 'package:iquiz/features/config/data_source/local/config_local_data_source_impl.dart';
import 'package:iquiz/features/config/data_source/remote/config_remote_data_source.dart';
import 'package:iquiz/features/config/data_source/remote/config_remote_data_source_impl.dart';
import 'package:iquiz/features/config/repositories/config_repository.dart';
import 'package:iquiz/features/config/repositories/config_repository_impl.dart';
import 'package:iquiz/features/config/usecases/watch_config_use_case.dart';

final firebaseRemoteConfigProvider = Provider<FirebaseRemoteConfig>((ref) {
  return FirebaseRemoteConfig.instance;
});

final configLocalDataSourceProvider = Provider<ConfigLocalDataSource>((ref) {
  return ConfigLocalDataSourceImpl();
});

final configRemoteDataSourceProvider = Provider<ConfigRemoteDataSource>((ref) {
  return ConfigRemoteDataSourceImpl(
    remoteConfig: ref.watch(firebaseRemoteConfigProvider),
  );
});

final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  return ConfigRepositoryImpl(
    localDataSource: ref.watch(configLocalDataSourceProvider),
    remoteDataSource: ref.watch(configRemoteDataSourceProvider),
  );
});

final watchConfigUseCaseProvider = Provider<WatchConfigUseCase>((ref) {
  return WatchConfigUseCase(ref.watch(configRepositoryProvider));
});
