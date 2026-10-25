import 'package:iquiz/features/config/data_source/local/models/local_config_model.dart';
import 'package:iquiz/features/config/data_source/remote/models/remote_config_model.dart';
import 'package:iquiz/features/config/repositories/entities/config_entity.dart';
import 'package:iquiz/features/config/repositories/entities/notice_detail_entity.dart';

abstract final class ConfigMapper {
  static ConfigEntity fromModels({
    required LocalConfigModel local,
    required RemoteConfigModel remote,
  }) {
    return ConfigEntity(
      baseUrl: remote.baseUrl,
      enabled: remote.enabled,
      minBuildNumber: remote.minBuildNumber,
      minVersion: remote.minVersion,
      noticeUrl: remote.noticeUrl,
      title: remote.title,
      description: remote.description,
      details: remote.details
          .map(
            (detail) => NoticeDetailEntity(
              title: detail.title,
              description: detail.description,
            ),
          )
          .toList(),
      version: local.version,
      buildNumber: local.buildNumber,
      platform: local.platform,
    );
  }
}
