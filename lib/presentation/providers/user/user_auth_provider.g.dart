// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// TechTalk의 UserAuth와 같은 역할. 화면에는 토큰 대신 사용자/인증 상태만 제공한다.

@ProviderFor(UserAuth)
final userAuthProvider = UserAuthProvider._();

/// TechTalk의 UserAuth와 같은 역할. 화면에는 토큰 대신 사용자/인증 상태만 제공한다.
final class UserAuthProvider
    extends $NotifierProvider<UserAuth, UserAuthState> {
  /// TechTalk의 UserAuth와 같은 역할. 화면에는 토큰 대신 사용자/인증 상태만 제공한다.
  UserAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userAuthHash();

  @$internal
  @override
  UserAuth create() => UserAuth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserAuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserAuthState>(value),
    );
  }
}

String _$userAuthHash() => r'dc3d65125edf7e7ef92fd3ebf50d1e4d18add083';

/// TechTalk의 UserAuth와 같은 역할. 화면에는 토큰 대신 사용자/인증 상태만 제공한다.

abstract class _$UserAuth extends $Notifier<UserAuthState> {
  UserAuthState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UserAuthState, UserAuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserAuthState, UserAuthState>,
              UserAuthState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
