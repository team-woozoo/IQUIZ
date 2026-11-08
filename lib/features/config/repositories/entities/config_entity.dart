import 'package:iquiz/features/config/data_source/local/models/local_config_model.dart';
import 'package:iquiz/features/config/data_source/remote/models/remote_config_model.dart';
import 'package:iquiz/features/config/repositories/entities/notice_detail_entity.dart';
import 'package:iquiz/features/config/repositories/enums/config_platform.enum.dart';

final class ConfigEntity {
  const ConfigEntity({
    required this.baseUrl,
    required this.enabled,
    required this.minBuildNumber,
    required this.noticeUrl,
    required this.title,
    required this.description,
    required this.details,
    required this.version,
    required this.buildNumber,
    required this.platform,
    required this.minVersion,
  });

  factory ConfigEntity.fromModels({
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
      details: remote.details.map(NoticeDetailEntity.fromModel).toList(),
      version: local.version,
      buildNumber: local.buildNumber,
      platform: local.platform,
    );
  }

  final bool enabled;
  final int minBuildNumber;
  final Uri noticeUrl;
  final String baseUrl;
  final String title;
  final String description;
  final String version;
  final int buildNumber;
  final String minVersion;
  final ConfigPlatform platform;
  final List<NoticeDetailEntity> details;

  /// 강제 업데이트 여부
  bool get isUpdate => enabled && buildNumber < minBuildNumber;
}
