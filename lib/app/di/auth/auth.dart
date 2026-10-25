import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/environment/flavor.dart';
import 'package:iquiz/features/auth/data_source/local/auth_local_data_source.dart';
import 'package:iquiz/features/auth/data_source/local/auth_local_data_source_impl.dart';
import 'package:iquiz/features/auth/data_source/remote/auth_remote_data_source.dart';
import 'package:iquiz/features/auth/data_source/remote/auth_remote_data_source_impl.dart';
import 'package:iquiz/features/auth/repositories/auth_repository.dart';
import 'package:iquiz/features/auth/repositories/auth_repository_impl.dart';
import 'package:iquiz/features/auth/services/auth_token_manager.dart';
import 'package:iquiz/features/auth/usecases/restore_auth_use_case.dart';
import 'package:iquiz/features/auth/usecases/sign_in_use_case.dart';
import 'package:iquiz/features/auth/usecases/sign_out_use_case.dart';
import 'package:iquiz/features/auth/usecases/sign_up_use_case.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(
    storage: const FlutterSecureStorage(),
    key: 'iquiz.${Flavor.instance.env.name}.auth.tokens',
  );
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return const AuthRemoteDataSourceImpl();
});

final authTokenManagerProvider = Provider<AuthTokenManager>((ref) {
  final manager = AuthTokenManager(
    local: ref.watch(authLocalDataSourceProvider),
    remote: ref.watch(authRemoteDataSourceProvider),
  );
  ref.onDispose(manager.dispose);
  return manager;
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    tokens: ref.watch(authTokenManagerProvider),
  ),
);

final signInUseCaseProvider = Provider<SignInUseCase>(
  (ref) => SignInUseCase(ref.watch(authRepositoryProvider)),
);
final signUpUseCaseProvider = Provider<SignUpUseCase>(
  (ref) => SignUpUseCase(ref.watch(authRepositoryProvider)),
);
final signOutUseCaseProvider = Provider<SignOutUseCase>(
  (ref) => SignOutUseCase(ref.watch(authRepositoryProvider)),
);
final restoreAuthUseCaseProvider = Provider<RestoreAuthUseCase>(
  (ref) => RestoreAuthUseCase(ref.watch(authRepositoryProvider)),
);
