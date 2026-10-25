// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RouterState)
final routerStateProvider = RouterStateProvider._();

final class RouterStateProvider
    extends $NotifierProvider<RouterState, GoRouter> {
  RouterStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerStateHash();

  @$internal
  @override
  RouterState create() => RouterState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerStateHash() => r'92dc64e4c780ea79445fede8b6d8d666c39ceb18';

abstract class _$RouterState extends $Notifier<GoRouter> {
  GoRouter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<GoRouter, GoRouter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GoRouter, GoRouter>,
              GoRouter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
