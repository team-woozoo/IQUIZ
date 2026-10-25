import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/config/repositories/config_repository.dart';
import 'package:iquiz/features/config/repositories/entities/config_entity.dart';

class WatchConfigUseCase {
  WatchConfigUseCase(this._repository);
  final ConfigRepository _repository;

  Stream<Result<ConfigEntity>> call() => _repository.watchConfig();
}
