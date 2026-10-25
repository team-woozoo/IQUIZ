import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/config/repositories/entities/config_entity.dart';

abstract class ConfigRepository {
  /// 로컬 앱 정보와 서버 설정을 함께 조회해 현재 앱 설정을 반환
  Future<Result<ConfigEntity>> getConfig();

  /// 서버 설정 변경을 구독하고 로컬 앱 정보와 결합한 앱 설정을 전달
  Stream<Result<ConfigEntity>> watchConfig();
}
