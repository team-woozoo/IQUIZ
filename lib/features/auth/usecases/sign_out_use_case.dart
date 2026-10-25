import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/auth/repositories/auth_repository.dart';

final class SignOutUseCase {
  const SignOutUseCase(this.repository);
  final AuthRepository repository;

  Future<Result<void>> call() => repository.signOut();
}
