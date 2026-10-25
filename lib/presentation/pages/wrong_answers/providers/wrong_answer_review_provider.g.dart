// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wrong_answer_review_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WrongAnswerReview)
final wrongAnswerReviewProvider = WrongAnswerReviewFamily._();

final class WrongAnswerReviewProvider
    extends $AsyncNotifierProvider<WrongAnswerReview, QuizSubmissionEntity?> {
  WrongAnswerReviewProvider._({
    required WrongAnswerReviewFamily super.from,
    required int super.argument,
  }) : super(
         retry: _noRetry,
         name: r'wrongAnswerReviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$wrongAnswerReviewHash();

  @override
  String toString() {
    return r'wrongAnswerReviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WrongAnswerReview create() => WrongAnswerReview();

  @override
  bool operator ==(Object other) {
    return other is WrongAnswerReviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$wrongAnswerReviewHash() => r'9a2ee4456264e278f524f547d89aa23bdfedda2d';

final class WrongAnswerReviewFamily extends $Family
    with
        $ClassFamilyOverride<
          WrongAnswerReview,
          AsyncValue<QuizSubmissionEntity?>,
          QuizSubmissionEntity?,
          FutureOr<QuizSubmissionEntity?>,
          int
        > {
  WrongAnswerReviewFamily._()
    : super(
        retry: _noRetry,
        name: r'wrongAnswerReviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WrongAnswerReviewProvider call(int questionId) =>
      WrongAnswerReviewProvider._(argument: questionId, from: this);

  @override
  String toString() => r'wrongAnswerReviewProvider';
}

abstract class _$WrongAnswerReview
    extends $AsyncNotifier<QuizSubmissionEntity?> {
  late final _$args = ref.$arg as int;
  int get questionId => _$args;

  FutureOr<QuizSubmissionEntity?> build(int questionId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<QuizSubmissionEntity?>, QuizSubmissionEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<QuizSubmissionEntity?>,
                QuizSubmissionEntity?
              >,
              AsyncValue<QuizSubmissionEntity?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
