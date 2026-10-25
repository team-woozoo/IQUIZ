import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/auth/repositories/auth_repository.dart';
import 'package:iquiz/features/auth/repositories/entities/user_entity.dart';

final class SignInUseCase {
  const SignInUseCase(this.repository);
  final AuthRepository repository;

  Future<Result<UserEntity>> call({
    required String email,
    required String password,
  }) => repository.signIn(email: email, password: password);
}
