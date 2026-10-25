// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_bottom_navigation.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HomeBottomNavigation)
final homeBottomNavigationProvider = HomeBottomNavigationProvider._();

final class HomeBottomNavigationProvider
    extends $NotifierProvider<HomeBottomNavigation, HomeNavigationTab> {
  HomeBottomNavigationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeBottomNavigationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeBottomNavigationHash();

  @$internal
  @override
  HomeBottomNavigation create() => HomeBottomNavigation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeNavigationTab value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeNavigationTab>(value),
    );
  }
}

String _$homeBottomNavigationHash() =>
    r'70ba310190090b0d9fe3babbfdf8c9ba91257a12';

abstract class _$HomeBottomNavigation extends $Notifier<HomeNavigationTab> {
  HomeNavigationTab build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HomeNavigationTab, HomeNavigationTab>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeNavigationTab, HomeNavigationTab>,
              HomeNavigationTab,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
