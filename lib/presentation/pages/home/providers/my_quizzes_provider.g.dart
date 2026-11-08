// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_quizzes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myQuizzes)
final myQuizzesProvider = MyQuizzesProvider._();

final class MyQuizzesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<QuizSummaryEntity>>,
          List<QuizSummaryEntity>,
          FutureOr<List<QuizSummaryEntity>>
        >
    with
        $FutureModifier<List<QuizSummaryEntity>>,
        $FutureProvider<List<QuizSummaryEntity>> {
  MyQuizzesProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'myQuizzesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myQuizzesHash();

  @$internal
  @override
  $FutureProviderElement<List<QuizSummaryEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<QuizSummaryEntity>> create(Ref ref) {
    return myQuizzes(ref);
  }
}

String _$myQuizzesHash() => r'0240222b65495dd8ce2cc81d53634e5075c878b2';
