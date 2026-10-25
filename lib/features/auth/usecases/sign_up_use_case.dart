import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/auth/repositories/auth_repository.dart';

final class SignUpUseCase {
  const SignUpUseCase(this.repository);
  final AuthRepository repository;

  Future<Result<int>> call({
    required String email,
    required String password,
    required String nickname,
  }) => repository.signUp(email: email, password: password, nickname: nickname);
}
