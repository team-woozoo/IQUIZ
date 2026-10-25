// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_route_arg.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(quizRouteArg)
final quizRouteArgProvider = QuizRouteArgProvider._();

final class QuizRouteArgProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  QuizRouteArgProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quizRouteArgProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[],
        $allTransitiveDependencies: <ProviderOrFamily>[],
      );

  @override
  String debugGetCreateSourceHash() => _$quizRouteArgHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return quizRouteArg(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$quizRouteArgHash() => r'5970df91a20697a2980b41b1efcc0039edbe6c3c';
