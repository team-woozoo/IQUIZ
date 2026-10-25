// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_upload_process.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QuizUploadProcess)
final quizUploadProcessProvider = QuizUploadProcessFamily._();

final class QuizUploadProcessProvider
    extends $StreamNotifierProvider<QuizUploadProcess, QuizGenerationState> {
  QuizUploadProcessProvider._({
    required QuizUploadProcessFamily super.from,
    required ({
      List<int>? fileBytes,
      String? fileName,
      int? materialId,
      int? conceptId,
      QuizGenerationOptionsEntity options,
      String? title,
    })
    super.argument,
  }) : super(
         retry: _noRetry,
         name: r'quizUploadProcessProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$quizUploadProcessHash();

  @override
  String toString() {
    return r'quizUploadProcessProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  QuizUploadProcess create() => QuizUploadProcess();

  @override
  bool operator ==(Object other) {
    return other is QuizUploadProcessProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$quizUploadProcessHash() => r'54ab949b2bc1e0423d474508d9b48d95a6bce973';

final class QuizUploadProcessFamily extends $Family
    with
        $ClassFamilyOverride<
          QuizUploadProcess,
          AsyncValue<QuizGenerationState>,
          QuizGenerationState,
          Stream<QuizGenerationState>,
          ({
            List<int>? fileBytes,
            String? fileName,
            int? materialId,
            int? conceptId,
            QuizGenerationOptionsEntity options,
            String? title,
          })
        > {
  QuizUploadProcessFamily._()
    : super(
        retry: _noRetry,
        name: r'quizUploadProcessProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  QuizUploadProcessProvider call({
    List<int>? fileBytes,
    String? fileName,
    int? materialId,
    int? conceptId,
    required QuizGenerationOptionsEntity options,
    String? title,
  }) => QuizUploadProcessProvider._(
    argument: (
      fileBytes: fileBytes,
      fileName: fileName,
      materialId: materialId,
      conceptId: conceptId,
      options: options,
      title: title,
    ),
    from: this,
  );

  @override
  String toString() => r'quizUploadProcessProvider';
}

abstract class _$QuizUploadProcess
    extends $StreamNotifier<QuizGenerationState> {
  late final _$args =
      ref.$arg
          as ({
            List<int>? fileBytes,
            String? fileName,
            int? materialId,
            int? conceptId,
            QuizGenerationOptionsEntity options,
            String? title,
          });
  List<int>? get fileBytes => _$args.fileBytes;
  String? get fileName => _$args.fileName;
  int? get materialId => _$args.materialId;
  int? get conceptId => _$args.conceptId;
  QuizGenerationOptionsEntity get options => _$args.options;
  String? get title => _$args.title;

  Stream<QuizGenerationState> build({
    List<int>? fileBytes,
    String? fileName,
    int? materialId,
    int? conceptId,
    required QuizGenerationOptionsEntity options,
    String? title,
  });
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<QuizGenerationState>, QuizGenerationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<QuizGenerationState>, QuizGenerationState>,
              AsyncValue<QuizGenerationState>,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(
        fileBytes: _$args.fileBytes,
        fileName: _$args.fileName,
        materialId: _$args.materialId,
        conceptId: _$args.conceptId,
        options: _$args.options,
        title: _$args.title,
      ),
    );
  }
}
