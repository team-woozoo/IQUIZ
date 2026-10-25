// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_submit_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QuizSubmit)
final quizSubmitProvider = QuizSubmitProvider._();

final class QuizSubmitProvider
    extends $AsyncNotifierProvider<QuizSubmit, QuizSubmissionEntity?> {
  QuizSubmitProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'quizSubmitProvider',
        isAutoDispose: true,
        dependencies: <ProviderOrFamily>[quizRouteArgProvider],
        $allTransitiveDependencies: <ProviderOrFamily>[
          QuizSubmitProvider.$allTransitiveDependencies0,
        ],
      );

  static final $allTransitiveDependencies0 = quizRouteArgProvider;

  @override
  String debugGetCreateSourceHash() => _$quizSubmitHash();

  @$internal
  @override
  QuizSubmit create() => QuizSubmit();
}

String _$quizSubmitHash() => r'2a446dc817dc2e4d4e4e62682708f230328b9166';

abstract class _$QuizSubmit extends $AsyncNotifier<QuizSubmissionEntity?> {
  FutureOr<QuizSubmissionEntity?> build();
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
    return element.handleCreate(ref, build);
  }
}
