import 'package:flutter/foundation.dart';
import 'package:iquiz/core/logger/log.dart';
import 'package:iquiz/features/config/data_source/local/config_local_data_source.dart';
import 'package:iquiz/features/config/data_source/local/models/local_config_model.dart';
import 'package:iquiz/features/config/repositories/enums/config_platform.enum.dart';
import 'package:package_info_plus/package_info_plus.dart';

final class ConfigLocalDataSourceImpl implements ConfigLocalDataSource {
  @override
  Future<LocalConfigModel> getLocalConfig() async {
    try {
      final platform = switch (defaultTargetPlatform) {
        TargetPlatform.android => ConfigPlatform.android,
        TargetPlatform.iOS => ConfigPlatform.ios,
        _ => throw UnsupportedError(
          '지원하지 않는 플랫폼입니다: ${defaultTargetPlatform.name}. Android와 iOS만 지원합니다.',
        ),
      };

      final packageInfo = await PackageInfo.fromPlatform();

      return LocalConfigModel(
        version: packageInfo.version,
        buildNumber: int.parse(packageInfo.buildNumber),
        platform: platform,
      );
    } catch (error, stackTrace) {
      Log.e('로컬 설정 정보 조회 실패', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }
}
