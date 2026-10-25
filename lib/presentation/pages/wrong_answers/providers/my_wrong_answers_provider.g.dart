// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_wrong_answers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myWrongAnswers)
final myWrongAnswersProvider = MyWrongAnswersProvider._();

final class MyWrongAnswersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WrongAnswerEntity>>,
          List<WrongAnswerEntity>,
          FutureOr<List<WrongAnswerEntity>>
        >
    with
        $FutureModifier<List<WrongAnswerEntity>>,
        $FutureProvider<List<WrongAnswerEntity>> {
  MyWrongAnswersProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'myWrongAnswersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myWrongAnswersHash();

  @$internal
  @override
  $FutureProviderElement<List<WrongAnswerEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WrongAnswerEntity>> create(Ref ref) {
    return myWrongAnswers(ref);
  }
}

String _$myWrongAnswersHash() => r'baf88b8b6b0012e1ecbbb3ea1aeb0de0472ee4de';
