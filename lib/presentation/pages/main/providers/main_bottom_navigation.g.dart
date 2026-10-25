// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main_bottom_navigation.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MainBottomNavigation)
final mainBottomNavigationProvider = MainBottomNavigationProvider._();

final class MainBottomNavigationProvider
    extends $NotifierProvider<MainBottomNavigation, MainNavigationTab> {
  MainBottomNavigationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mainBottomNavigationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mainBottomNavigationHash();

  @$internal
  @override
  MainBottomNavigation create() => MainBottomNavigation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MainNavigationTab value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MainNavigationTab>(value),
    );
  }
}

String _$mainBottomNavigationHash() =>
    r'57a795ce27f95462e0d47fe9536fe853b35ef7fa';

abstract class _$MainBottomNavigation extends $Notifier<MainNavigationTab> {
  MainNavigationTab build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MainNavigationTab, MainNavigationTab>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MainNavigationTab, MainNavigationTab>,
              MainNavigationTab,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
