// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detect_force_update_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DetectForceUpdate)
final detectForceUpdateProvider = DetectForceUpdateProvider._();

final class DetectForceUpdateProvider
    extends $NotifierProvider<DetectForceUpdate, void> {
  DetectForceUpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'detectForceUpdateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$detectForceUpdateHash();

  @$internal
  @override
  DetectForceUpdate create() => DetectForceUpdate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$detectForceUpdateHash() => r'57f1a735126b904ae984120c53abbe0ec8e61c42';

abstract class _$DetectForceUpdate extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
