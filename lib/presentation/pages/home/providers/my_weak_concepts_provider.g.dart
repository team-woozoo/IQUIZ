// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_weak_concepts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myWeakConcepts)
final myWeakConceptsProvider = MyWeakConceptsProvider._();

final class MyWeakConceptsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WeakConceptEntity>>,
          List<WeakConceptEntity>,
          FutureOr<List<WeakConceptEntity>>
        >
    with
        $FutureModifier<List<WeakConceptEntity>>,
        $FutureProvider<List<WeakConceptEntity>> {
  MyWeakConceptsProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'myWeakConceptsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myWeakConceptsHash();

  @$internal
  @override
  $FutureProviderElement<List<WeakConceptEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WeakConceptEntity>> create(Ref ref) {
    return myWeakConcepts(ref);
  }
}

String _$myWeakConceptsHash() => r'9f5b746d27551585121861bfa22e4d0cf1e04c13';
