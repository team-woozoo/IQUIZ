// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_provier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppConfigProvier)
final appConfigProvierProvider = AppConfigProvierProvider._();

final class AppConfigProvierProvider
    extends $StreamNotifierProvider<AppConfigProvier, ConfigEntity> {
  AppConfigProvierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appConfigProvierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appConfigProvierHash();

  @$internal
  @override
  AppConfigProvier create() => AppConfigProvier();
}

String _$appConfigProvierHash() => r'57906a431409ec288b819d9f37bdd9f1a99d3f33';

abstract class _$AppConfigProvier extends $StreamNotifier<ConfigEntity> {
  Stream<ConfigEntity> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ConfigEntity>, ConfigEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ConfigEntity>, ConfigEntity>,
              AsyncValue<ConfigEntity>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
