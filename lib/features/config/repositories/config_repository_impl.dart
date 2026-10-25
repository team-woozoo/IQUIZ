import 'dart:async';

import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/config/data_source/local/config_local_data_source.dart';
import 'package:iquiz/features/config/data_source/remote/config_remote_data_source.dart';
import 'package:iquiz/features/config/repositories/config_repository.dart';
import 'package:iquiz/features/config/repositories/entities/config_entity.dart';
import 'package:iquiz/features/config/repositories/mappers/config_mapper.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  ConfigRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  final ConfigLocalDataSource localDataSource;
  final ConfigRemoteDataSource remoteDataSource;

  @override
  Stream<Result<ConfigEntity>> watchConfig() => remoteDataSource
      .watchRemoteConfig()
      .asyncMap<Result<ConfigEntity>>((remote) async {
        final localConfig = await localDataSource.getLocalConfig();

        return Result.success(
          ConfigMapper.fromModels(local: localConfig, remote: remote),
        );
      })
      .transform(
        StreamTransformer<
          Result<ConfigEntity>,
          Result<ConfigEntity>
        >.fromHandlers(
          handleError: (error, stackTrace, sink) {
            sink.add(
              Result.failure<ConfigEntity>(
                error is Exception ? error : Exception(error),
              ),
            );
          },
        ),
      );

  @override
  Future<Result<ConfigEntity>> getConfig() async {
    try {
      final local = await localDataSource.getLocalConfig();
      final remote = await remoteDataSource.getRemoteConfig();

      return Result.success(
        ConfigMapper.fromModels(local: local, remote: remote),
      );
    } on Exception catch (e) {
      return Result.failure(Exception(e));
    }
  }
}
