import 'dart:async';

import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_options_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_generation_status.enum.dart';
import 'package:iquiz/presentation/pages/home/providers/my_quizzes_provider.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_upload/providers/quiz_generation_state.dart';
import 'package:iquiz/presentation/providers/quiz/quiz_generation_activity_provider.dart';
import 'package:iquiz/presentation/providers/material/material_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quiz_upload_process.g.dart';

// 업로드 요청이 자동 재시도로 중복 생성되지 않게 처리
Duration? _noRetry(int retryCount, Object error) => null;

@Riverpod(retry: _noRetry)
class QuizUploadProcess extends _$QuizUploadProcess {
  @override
  Stream<QuizGenerationState> build({
    List<int>? fileBytes,
    String? fileName,
    int? materialId,
    int? conceptId,
    required QuizGenerationOptionsEntity options,
    String? title,
  }) async* {
    final uploadFile = ref.read(uploadFileUseCaseProvider);
    final generateMaterial = ref.read(
      requestMaterialQuizGenerationUseCaseProvider,
    );
    final generateWeakness = ref.read(
      requestWeaknessQuizGenerationUseCaseProvider,
    );
    final watchGenerationJob = ref.read(watchGenerationJobUseCaseProvider);
    if (materialId == null &&
        conceptId == null &&
        (fileBytes == null || fileName == null)) {
      throw const FormatException('문제를 생성할 자료를 선택해 주세요.');
    }
    final activity = ref.read(quizGenerationActivityProvider.notifier);
    // 업로드 화면을 나가도 완료될 때까지 작업과 SSE 구독을 유지
    final retention = ref.keepAlive();
    yield QuizGenerationState(
      status: materialId == null && conceptId == null
          ? QuizGenerationStatus.uploading
          : QuizGenerationStatus.pending,
    );
    if (!ref.mounted) {
      retention.close();
      return;
    }
    final materialTitle = title?.trim();
    final fallbackTitle = fileName == null
        ? '학습 자료'
        : fileName.toLowerCase().endsWith('.pdf')
        ? fileName.substring(0, fileName.length - 4)
        : fileName;
    Future<void> Function()? cancelEvents;
    var materialDataRefreshedAtTerminal = false;
    final activityId = activity.start(
      title: materialTitle == null || materialTitle.isEmpty
          ? fallbackTitle
          : materialTitle,
      release: () {
        retention.close();
        final cancel = cancelEvents;
        if (cancel != null) unawaited(cancel());
      },
    );
    activity.retain(
      activityId,
      quizUploadProcessProvider(
        fileBytes: fileBytes,
        fileName: fileName,
        materialId: materialId,
        conceptId: conceptId,
        options: options,
        title: title,
      ),
    );
    try {
      final uploadResult = conceptId != null
          ? await generateWeakness(conceptId: conceptId, options: options)
          : materialId != null
          ? await generateMaterial(materialId: materialId, options: options)
          : await uploadFile(
              fileBytes: fileBytes!,
              fileName: fileName!,
              options: options,
              title: title,
            );
      if (!ref.mounted || !activity.contains(activityId)) return;
      final jobId = uploadResult.fold(
        onSuccess: (jobId) => jobId,
        onFailure: (error) => throw error,
      );
      activity.update(activityId, QuizGenerationStatus.pending);
      invalidateMaterialData(ref, materialId: materialId);
      yield QuizGenerationState(
        status: QuizGenerationStatus.pending,
        jobId: jobId,
      );
      if (!ref.mounted || !activity.contains(activityId)) return;

      final events = StreamIterator(watchGenerationJob(jobId: jobId));
      cancelEvents = events.cancel;
      while (await events.moveNext()) {
        if (!ref.mounted || !activity.contains(activityId)) return;
        final event = events.current;
        final job = event.fold(
          onSuccess: (job) => job,
          onFailure: (error) => throw error,
        );
        activity.update(activityId, job.status);
        if (job.status == QuizGenerationStatus.done) {
          ref.invalidate(myQuizzesProvider);
        }
        if (job.status == QuizGenerationStatus.done ||
            job.status == QuizGenerationStatus.failed) {
          invalidateMaterialData(ref, materialId: materialId);
          materialDataRefreshedAtTerminal = true;
        }
        yield QuizGenerationState(
          status: job.status,
          jobId: job.jobId,
          quizId: job.quizId,
          error: job.error,
        );
        if (job.status == QuizGenerationStatus.done ||
            job.status == QuizGenerationStatus.failed) {
          return;
        }
      }
    } finally {
      await cancelEvents?.call();
      // 업로드 후 생성 요청 실패나 SSE 실패 시에도 자료를 다시 조회
      if (ref.mounted && !materialDataRefreshedAtTerminal) {
        invalidateMaterialData(ref, materialId: materialId);
      }
      if (ref.mounted && activity.contains(activityId)) {
        activity.finish(activityId);
      }
      retention.close();
    }
  }
}
