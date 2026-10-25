import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/features/quiz/repositories/entities/material_concept_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_summary_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/study_material_entity.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'material_providers.g.dart';

Duration? _noRetry(int retryCount, Object error) => null;

int? _watchUserId(Ref ref) => ref.watch(
  userAuthProvider.select(
    (auth) => auth.status == AuthStatus.authenticated ? auth.user?.id : null,
  ),
);

@Riverpod(retry: _noRetry)
Future<List<StudyMaterialEntity>> myMaterials(Ref ref) async {
  if (_watchUserId(ref) == null) return const [];
  final result = await ref.watch(getMyMaterialsUseCaseProvider)();
  return result.fold(
    onSuccess: (items) => items,
    onFailure: (error) => throw error,
  );
}

/// 미로그인 상태는 null, 자료 없음은 MATERIAL_NOT_FOUND 오류로 구분
@Riverpod(retry: _noRetry)
Future<StudyMaterialEntity?> myMaterial(
  Ref ref, {
  required int materialId,
}) async {
  if (_watchUserId(ref) == null) return null;
  final result = await ref.watch(getMyMaterialUseCaseProvider)(
    materialId: materialId,
  );
  return result.fold(
    onSuccess: (item) => item,
    onFailure: (error) => throw error,
  );
}

@Riverpod(retry: _noRetry)
Future<List<MaterialConceptEntity>> myMaterialConcepts(
  Ref ref, {
  required int materialId,
}) async {
  if (_watchUserId(ref) == null) return const [];
  final result = await ref.watch(getMyMaterialConceptsUseCaseProvider)(
    materialId: materialId,
  );
  return result.fold(
    onSuccess: (items) => items,
    onFailure: (error) => throw error,
  );
}

/// 전체 퀴즈 목록과 별개로 자료 ID별 조회·캐시를 유지
@Riverpod(retry: _noRetry)
Future<List<QuizSummaryEntity>> materialQuizzes(
  Ref ref, {
  required int materialId,
}) async {
  if (_watchUserId(ref) == null) return const [];
  final result = await ref.watch(getMyQuizzesUseCaseProvider)(
    materialId: materialId,
  );
  return result.fold(
    onSuccess: (items) => items,
    onFailure: (error) => throw error,
  );
}

/// 생성 결과의 자료 ID를 모르면 전체 family를, 알면 해당 자료만 갱신
void invalidateMaterialData(Ref ref, {int? materialId}) {
  ref.invalidate(myMaterialsProvider);
  if (materialId == null) {
    ref.invalidate(myMaterialProvider);
    ref.invalidate(myMaterialConceptsProvider);
    ref.invalidate(materialQuizzesProvider);
  } else {
    ref.invalidate(myMaterialProvider(materialId: materialId));
    ref.invalidate(myMaterialConceptsProvider(materialId: materialId));
    ref.invalidate(materialQuizzesProvider(materialId: materialId));
  }
}
