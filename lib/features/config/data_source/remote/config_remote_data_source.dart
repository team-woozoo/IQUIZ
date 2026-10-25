import 'package:iquiz/features/config/data_source/remote/models/remote_config_model.dart';

abstract class ConfigRemoteDataSource {
  Future<RemoteConfigModel> getRemoteConfig();

  Stream<RemoteConfigModel> watchRemoteConfig();
}
