// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_animation.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 앱 시작 시 스플래시 애니메이션을 한 번 재생했는지 공유한다.

@ProviderFor(SplashAnimation)
final splashAnimationProvider = SplashAnimationProvider._();

/// 앱 시작 시 스플래시 애니메이션을 한 번 재생했는지 공유한다.
final class SplashAnimationProvider
    extends $NotifierProvider<SplashAnimation, bool> {
  /// 앱 시작 시 스플래시 애니메이션을 한 번 재생했는지 공유한다.
  SplashAnimationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splashAnimationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splashAnimationHash();

  @$internal
  @override
  SplashAnimation create() => SplashAnimation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$splashAnimationHash() => r'1259e98bd5d895bd26f860e96c9ad3735d1bcb65';

/// 앱 시작 시 스플래시 애니메이션을 한 번 재생했는지 공유한다.

abstract class _$SplashAnimation extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
