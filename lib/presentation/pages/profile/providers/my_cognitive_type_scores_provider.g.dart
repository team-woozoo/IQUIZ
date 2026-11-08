// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_cognitive_type_scores_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myCognitiveTypeScores)
final myCognitiveTypeScoresProvider = MyCognitiveTypeScoresProvider._();

final class MyCognitiveTypeScoresProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CognitiveTypeScoreEntity>>,
          List<CognitiveTypeScoreEntity>,
          FutureOr<List<CognitiveTypeScoreEntity>>
        >
    with
        $FutureModifier<List<CognitiveTypeScoreEntity>>,
        $FutureProvider<List<CognitiveTypeScoreEntity>> {
  MyCognitiveTypeScoresProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'myCognitiveTypeScoresProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myCognitiveTypeScoresHash();

  @$internal
  @override
  $FutureProviderElement<List<CognitiveTypeScoreEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CognitiveTypeScoreEntity>> create(Ref ref) {
    return myCognitiveTypeScores(ref);
  }
}

String _$myCognitiveTypeScoresHash() =>
    r'f083400b12ef45f4f8dcd51dd64b4f3ad9b117a2';
