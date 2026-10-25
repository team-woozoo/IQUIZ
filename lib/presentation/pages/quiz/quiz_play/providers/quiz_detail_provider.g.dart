// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(quizDetail)
final quizDetailProvider = QuizDetailProvider._();

final class QuizDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<QuizEntity>,
          QuizEntity,
          FutureOr<QuizEntity>
        >
    with $FutureModifier<QuizEntity>, $FutureProvider<QuizEntity> {
  QuizDetailProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quizDetailProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[quizRouteArgProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          QuizDetailProvider.$allTransitiveDependencies0,
        ],
      );

  static final $allTransitiveDependencies0 = quizRouteArgProvider;

  @override
  String debugGetCreateSourceHash() => _$quizDetailHash();

  @$internal
  @override
  $FutureProviderElement<QuizEntity> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<QuizEntity> create(Ref ref) {
    return quizDetail(ref);
  }
}

String _$quizDetailHash() => r'e543a6f8db75472fef5defacf8fbc965af8fc22a';
