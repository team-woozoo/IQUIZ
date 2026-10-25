import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:iquiz/core/logger/log.dart';
import 'package:iquiz/features/config/data_source/remote/config_remote_data_source.dart';
import 'package:iquiz/features/config/data_source/remote/models/notice_detail_model.dart';
import 'package:iquiz/features/config/data_source/remote/models/remote_config_model.dart';

final class ConfigRemoteDataSourceImpl implements ConfigRemoteDataSource {
  ConfigRemoteDataSourceImpl({required this.remoteConfig});

  final FirebaseRemoteConfig remoteConfig;

  @override
  Future<RemoteConfigModel> getRemoteConfig() async {
    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );

      await remoteConfig.fetchAndActivate();

      Log.d({
        'event': 'remote_config_initial_fetch_completed',
        'projectId': remoteConfig.app.options.projectId,
        'fetchStatus': remoteConfig.lastFetchStatus.name,
        'lastFetchTime': remoteConfig.lastFetchTime.toIso8601String(),
        'enabled': remoteConfig.getBool('enabled'),
        'enabledSource': remoteConfig.getValue('enabled').source.name,
        'minBuildNumber': remoteConfig.getInt('min_build_number'),
        'details': remoteConfig.getString('details'),
      });

      return _readRemoteConfig();
    } catch (e, stackTrace) {
      Log.e('설정 정보 조회 실패', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Stream<RemoteConfigModel> watchRemoteConfig() => remoteConfig.onConfigUpdated
      .handleError((Object error, StackTrace stackTrace) {
        Log.e('Remote Config 실시간 연결 오류', error: error, stackTrace: stackTrace);
        Error.throwWithStackTrace(error, stackTrace);
      })
      .asyncMap((event) async {
        final timer = Stopwatch()..start();
        try {
          Log.d({
            'event': 'remote_config_update_received',
            'receivedAt': DateTime.now().toIso8601String(),
            'projectId': remoteConfig.app.options.projectId,
            'updatedKeys': event.updatedKeys.toList(),
          });

          final activated = await remoteConfig.activate();

          Log.d({
            'event': 'remote_config_activation_completed',
            'completedAt': DateTime.now().toIso8601String(),
            'activated': activated,
            'activationElapsedMs': timer.elapsedMilliseconds,
            'title': remoteConfig.getString('title'),
            'projectId': remoteConfig.app.options.projectId,
            'fetchStatus': remoteConfig.lastFetchStatus.name,
            'lastFetchTime': remoteConfig.lastFetchTime.toIso8601String(),
            'enabled': remoteConfig.getBool('enabled'),
            'enabledSource': remoteConfig.getValue('enabled').source.name,
            'minBuildNumber': remoteConfig.getInt('min_build_number'),
            'details': remoteConfig.getString('details'),
          });

          return _readRemoteConfig();
        } catch (e, stackTrace) {
          Log.e('설정 정보 실시간 갱신 실패', error: e, stackTrace: stackTrace);
          rethrow;
        }
      });

  RemoteConfigModel _readRemoteConfig() {
    return RemoteConfigModel(
      enabled: remoteConfig.getBool('enabled'),
      minBuildNumber: remoteConfig.getInt('min_build_number'),
      noticeUrl: Uri.parse(remoteConfig.getString('notice_url').trim()),
      title: remoteConfig.getString('title'),
      description: remoteConfig.getString('description'),
      details: NoticeDetailModel.listFromJsonString(
        remoteConfig.getString('details'),
      ),
      baseUrl: remoteConfig.getString('base_url'),
      minVersion: remoteConfig.getString('min_version'),
    );
  }
}
