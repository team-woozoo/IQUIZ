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
