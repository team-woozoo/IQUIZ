import 'package:iquiz/features/config/repositories/enums/config_platform.enum.dart';

///
/// 설치된 앱 버전·플랫폼 정보
///
class LocalConfigModel {
  const LocalConfigModel({
    required this.version,
    required this.buildNumber,
    required this.platform,
  });

  final String version;
  final int buildNumber;
  final ConfigPlatform platform;
}
