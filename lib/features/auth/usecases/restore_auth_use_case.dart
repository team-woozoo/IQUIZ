import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/auth/repositories/auth_repository.dart';
import 'package:iquiz/features/auth/repositories/entities/user_entity.dart';

final class RestoreAuthUseCase {
  const RestoreAuthUseCase(this.repository);
  final AuthRepository repository;

  Future<Result<UserEntity?>> call() => repository.restore();
}
