import 'package:iquiz/features/config/data_source/local/models/local_config_model.dart';

abstract class ConfigLocalDataSource {
  Future<LocalConfigModel> getLocalConfig();
}
