// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_result_route_arg.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(quizResultRouteArg)
final quizResultRouteArgProvider = QuizResultRouteArgProvider._();

final class QuizResultRouteArgProvider
    extends
        $FunctionalProvider<
          QuizResultRouteArg?,
          QuizResultRouteArg?,
          QuizResultRouteArg?
        >
    with $Provider<QuizResultRouteArg?> {
  QuizResultRouteArgProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quizResultRouteArgProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[],
        $allTransitiveDependencies: <ProviderOrFamily>[],
      );

  @override
  String debugGetCreateSourceHash() => _$quizResultRouteArgHash();

  @$internal
  @override
  $ProviderElement<QuizResultRouteArg?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  QuizResultRouteArg? create(Ref ref) {
    return quizResultRouteArg(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuizResultRouteArg? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuizResultRouteArg?>(value),
    );
  }
}

String _$quizResultRouteArgHash() =>
    r'01fdcdd058f2eaa64eb5c1431e5c97d62b96512e';
