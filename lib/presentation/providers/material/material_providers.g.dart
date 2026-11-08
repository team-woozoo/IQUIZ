// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myMaterials)
final myMaterialsProvider = MyMaterialsProvider._();

final class MyMaterialsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StudyMaterialEntity>>,
          List<StudyMaterialEntity>,
          FutureOr<List<StudyMaterialEntity>>
        >
    with
        $FutureModifier<List<StudyMaterialEntity>>,
        $FutureProvider<List<StudyMaterialEntity>> {
  MyMaterialsProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'myMaterialsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myMaterialsHash();

  @$internal
  @override
  $FutureProviderElement<List<StudyMaterialEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StudyMaterialEntity>> create(Ref ref) {
    return myMaterials(ref);
  }
}

String _$myMaterialsHash() => r'aaeb8b62c1879cba2670611f3e27a46bd3725c64';

/// 미로그인 상태는 null, 자료 없음은 MATERIAL_NOT_FOUND 오류로 구분

@ProviderFor(myMaterial)
final myMaterialProvider = MyMaterialFamily._();

/// 미로그인 상태는 null, 자료 없음은 MATERIAL_NOT_FOUND 오류로 구분

final class MyMaterialProvider
    extends
        $FunctionalProvider<
          AsyncValue<StudyMaterialEntity?>,
          StudyMaterialEntity?,
          FutureOr<StudyMaterialEntity?>
        >
    with
        $FutureModifier<StudyMaterialEntity?>,
        $FutureProvider<StudyMaterialEntity?> {
  /// 미로그인 상태는 null, 자료 없음은 MATERIAL_NOT_FOUND 오류로 구분
  MyMaterialProvider._({
    required MyMaterialFamily super.from,
    required int super.argument,
  }) : super(
         retry: _noRetry,
         name: r'myMaterialProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myMaterialHash();

  @override
  String toString() {
    return r'myMaterialProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<StudyMaterialEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StudyMaterialEntity?> create(Ref ref) {
    final argument = this.argument as int;
    return myMaterial(ref, materialId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyMaterialProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myMaterialHash() => r'91c9ae6da9a217c44b2fe9eeae506506971f568e';

/// 미로그인 상태는 null, 자료 없음은 MATERIAL_NOT_FOUND 오류로 구분

final class MyMaterialFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<StudyMaterialEntity?>, int> {
  MyMaterialFamily._()
    : super(
        retry: _noRetry,
        name: r'myMaterialProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 미로그인 상태는 null, 자료 없음은 MATERIAL_NOT_FOUND 오류로 구분

  MyMaterialProvider call({required int materialId}) =>
      MyMaterialProvider._(argument: materialId, from: this);

  @override
  String toString() => r'myMaterialProvider';
}

@ProviderFor(myMaterialConcepts)
final myMaterialConceptsProvider = MyMaterialConceptsFamily._();

final class MyMaterialConceptsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MaterialConceptEntity>>,
          List<MaterialConceptEntity>,
          FutureOr<List<MaterialConceptEntity>>
        >
    with
        $FutureModifier<List<MaterialConceptEntity>>,
        $FutureProvider<List<MaterialConceptEntity>> {
  MyMaterialConceptsProvider._({
    required MyMaterialConceptsFamily super.from,
    required int super.argument,
  }) : super(
         retry: _noRetry,
         name: r'myMaterialConceptsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myMaterialConceptsHash();

  @override
  String toString() {
    return r'myMaterialConceptsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<MaterialConceptEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MaterialConceptEntity>> create(Ref ref) {
    final argument = this.argument as int;
    return myMaterialConcepts(ref, materialId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyMaterialConceptsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myMaterialConceptsHash() =>
    r'03b28c016b1ea4b63068fb99a5b10b30ff40371c';

final class MyMaterialConceptsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<MaterialConceptEntity>>, int> {
  MyMaterialConceptsFamily._()
    : super(
        retry: _noRetry,
        name: r'myMaterialConceptsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MyMaterialConceptsProvider call({required int materialId}) =>
      MyMaterialConceptsProvider._(argument: materialId, from: this);

  @override
  String toString() => r'myMaterialConceptsProvider';
}

/// 전체 퀴즈 목록과 별개로 자료 ID별 조회·캐시를 유지

@ProviderFor(materialQuizzes)
final materialQuizzesProvider = MaterialQuizzesFamily._();

/// 전체 퀴즈 목록과 별개로 자료 ID별 조회·캐시를 유지

final class MaterialQuizzesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<QuizSummaryEntity>>,
          List<QuizSummaryEntity>,
          FutureOr<List<QuizSummaryEntity>>
        >
    with
        $FutureModifier<List<QuizSummaryEntity>>,
        $FutureProvider<List<QuizSummaryEntity>> {
  /// 전체 퀴즈 목록과 별개로 자료 ID별 조회·캐시를 유지
  MaterialQuizzesProvider._({
    required MaterialQuizzesFamily super.from,
    required int super.argument,
  }) : super(
         retry: _noRetry,
         name: r'materialQuizzesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$materialQuizzesHash();

  @override
  String toString() {
    return r'materialQuizzesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<QuizSummaryEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<QuizSummaryEntity>> create(Ref ref) {
    final argument = this.argument as int;
    return materialQuizzes(ref, materialId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MaterialQuizzesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$materialQuizzesHash() => r'6e5ed487e54e7ef8ecf2b3003a7e0da46d565af0';

/// 전체 퀴즈 목록과 별개로 자료 ID별 조회·캐시를 유지

final class MaterialQuizzesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<QuizSummaryEntity>>, int> {
  MaterialQuizzesFamily._()
    : super(
        retry: _noRetry,
        name: r'materialQuizzesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 전체 퀴즈 목록과 별개로 자료 ID별 조회·캐시를 유지

  MaterialQuizzesProvider call({required int materialId}) =>
      MaterialQuizzesProvider._(argument: materialId, from: this);

  @override
  String toString() => r'materialQuizzesProvider';
}
