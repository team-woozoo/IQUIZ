import 'package:iquiz/app/di/auth/auth.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/auth/repositories/entities/user_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_auth_provider.g.dart';

enum AuthStatus { initializing, unauthenticated, authenticated, failure }

final class UserAuthState {
  const UserAuthState(this.status, {this.user, this.error});

  final AuthStatus status;
  final UserEntity? user;
  final Exception? error;

  @override
  String toString() => 'UserAuthState(${status.name})';
}

/// TechTalk의 UserAuth와 같은 역할. 화면에는 토큰 대신 사용자/인증 상태만 제공
@Riverpod(keepAlive: true)
class UserAuth extends _$UserAuth {
  int _operation = 0;

  @override
  UserAuthState build() {
    final manager = ref.watch(authTokenManagerProvider);
    void onSessionEnded() {
      _operation++;
      state = const UserAuthState(AuthStatus.unauthenticated);
    }

    manager.addListener(onSessionEnded);
    ref.onDispose(() => manager.removeListener(onSessionEnded));
    return const UserAuthState(AuthStatus.initializing);
  }

  void prepareInitialization() {
    state = const UserAuthState(AuthStatus.initializing);
  }

  void initializationFailed(Exception error) {
    state = UserAuthState(AuthStatus.failure, error: error);
  }

  Future<void> initialize() async {
    final operation = ++_operation;
    prepareInitialization();
    final result = await ref.read(restoreAuthUseCaseProvider)();
    if (!ref.mounted || operation != _operation) return;
    result.fold(
      onSuccess: (user) => state = UserAuthState(
        user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated,
        user: user,
      ),
      onFailure: initializationFailed,
    );
  }

  Future<Result<UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    final operation = ++_operation;
    final result = await ref.read(signInUseCaseProvider)(
      email: email,
      password: password,
    );
    if (ref.mounted && operation == _operation) {
      result.fold(
        onSuccess: (user) =>
            state = UserAuthState(AuthStatus.authenticated, user: user),
        onFailure: (_) {},
      );
    }
    return result;
  }

  Future<Result<void>> signOut() async {
    _operation++;
    return ref.read(signOutUseCaseProvider)();
  }
}
