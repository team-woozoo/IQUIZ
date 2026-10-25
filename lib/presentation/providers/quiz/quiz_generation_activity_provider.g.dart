// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_generation_activity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 앱에서 진행 중인 작업만 보관하며, 계정 변경 시 기존 작업의 보관을 해제합니다.

@ProviderFor(QuizGenerationActivity)
final quizGenerationActivityProvider = QuizGenerationActivityProvider._();

/// 앱에서 진행 중인 작업만 보관하며, 계정 변경 시 기존 작업의 보관을 해제합니다.
final class QuizGenerationActivityProvider
    extends
        $NotifierProvider<
          QuizGenerationActivity,
          List<QuizGenerationActivityEntry>
        > {
  /// 앱에서 진행 중인 작업만 보관하며, 계정 변경 시 기존 작업의 보관을 해제합니다.
  QuizGenerationActivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quizGenerationActivityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quizGenerationActivityHash();

  @$internal
  @override
  QuizGenerationActivity create() => QuizGenerationActivity();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<QuizGenerationActivityEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<QuizGenerationActivityEntry>>(
        value,
      ),
    );
  }
}

String _$quizGenerationActivityHash() =>
    r'3ab96e9b1fd42220129e5b14752b00514e7f08e5';

/// 앱에서 진행 중인 작업만 보관하며, 계정 변경 시 기존 작업의 보관을 해제합니다.

abstract class _$QuizGenerationActivity
    extends $Notifier<List<QuizGenerationActivityEntry>> {
  List<QuizGenerationActivityEntry> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              List<QuizGenerationActivityEntry>,
              List<QuizGenerationActivityEntry>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                List<QuizGenerationActivityEntry>,
                List<QuizGenerationActivityEntry>
              >,
              List<QuizGenerationActivityEntry>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
