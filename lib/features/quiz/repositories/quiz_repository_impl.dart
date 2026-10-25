import 'package:dio/dio.dart';
import 'package:iquiz/features/quiz/repositories/entities/wrong_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/mappers/wrong_answer_mapper.dart';
import 'package:iquiz/app/network/api_error.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/quiz_submit_model.dart';
import 'package:iquiz/features/quiz/data_source/remote/quiz_remote_data_source.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_submission_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_summary_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_job_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_options_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_generation_status.enum.dart';
import 'package:iquiz/features/quiz/repositories/mappers/quiz_generation_mapper.dart';
import 'package:iquiz/features/quiz/repositories/mappers/quiz_mapper.dart';
import 'package:iquiz/features/quiz/repositories/mappers/quiz_submission_mapper.dart';
import 'package:iquiz/features/quiz/repositories/mappers/quiz_summary_mapper.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository.dart';
import 'package:iquiz/features/quiz/repositories/entities/study_material_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/material_concept_entity.dart';
import 'package:iquiz/features/quiz/repositories/mappers/material_mapper.dart';

final class QuizRepositoryImpl implements QuizRepository {
  const QuizRepositoryImpl(this._quizRemoteDataSource);

  final QuizRemoteDataSource _quizRemoteDataSource;

  @override
  Future<Result<List<WrongAnswerEntity>>> getMyWrongAnswers() async {
    try {
      final response = await _quizRemoteDataSource.getMyWrongAnswers();
      return Result.success(
        List.unmodifiable(response.map((model) => model.toEntity())),
      );
    } on Exception catch (error) {
      return Result.failure(mapApiError(error));
    }
  }

  @override
  Future<Result<QuizSubmissionEntity>> submitWrongAnswerReview({
    required List<QuizAnswerEntity> answers,
  }) async {
    try {
      final response = await _quizRemoteDataSource.submitWrongAnswerReview(
        request: QuizSubmitModel(
          answers: answers.map((answer) => answer.toRequest()).toList(),
        ),
      );
      final submission = response.toEntity();
      final questionIds = answers.map((answer) => answer.questionId).toSet();
      if (submission.totalCount != questionIds.length ||
          submission.results.any(
            (result) => !questionIds.contains(result.questionId),
          )) {
        throw const FormatException('복습 채점 결과의 문제가 제출한 답안과 일치하지 않습니다.');
      }
      return Result.success(submission);
    } on Exception catch (error) {
      return Result.failure(mapApiError(error));
    }
  }

  @override
  Future<Result<List<QuizSummaryEntity>>> getMyQuizzes({
    int? materialId,
  }) async {
    try {
      final response = await _quizRemoteDataSource.getMyQuizzes(
        materialId: materialId,
      );
      return Result.success(
        List.unmodifiable(response.map((quiz) => quiz.toEntity())),
      );
    } on Exception catch (error) {
      return Result.failure(mapApiError(error));
    }
  }

  @override
  Future<Result<List<StudyMaterialEntity>>> getMyMaterials() async {
    try {
      final response = await _quizRemoteDataSource.getMyMaterials();
      return Result.success(
        List.unmodifiable(response.map((model) => model.toEntity())),
      );
    } on Exception catch (error) {
      return Result.failure(mapApiError(error));
    }
  }

  @override
  Future<Result<StudyMaterialEntity>> getMyMaterial({
    required int materialId,
  }) async {
    try {
      final response = await _quizRemoteDataSource.getMyMaterial(
        materialId: materialId,
      );
      return Result.success(response.toEntity());
    } on Exception catch (error) {
      return Result.failure(mapApiError(error));
    }
  }

  @override
  Future<Result<List<MaterialConceptEntity>>> getMyMaterialConcepts({
    required int materialId,
  }) async {
    try {
      final response = await _quizRemoteDataSource.getMyMaterialConcepts(
        materialId: materialId,
      );
      return Result.success(
        List.unmodifiable(response.map((model) => model.toEntity())),
      );
    } on Exception catch (error) {
      return Result.failure(mapApiError(error));
    }
  }

  @override
  Future<Result<int>> requestWeaknessQuizGeneration({
    required int conceptId,
    required QuizGenerationOptionsEntity options,
  }) async {
    try {
      final response = await _quizRemoteDataSource
          .requestWeaknessQuizGeneration(
            conceptId: conceptId,
            options: options.toRequest(),
          );
      if (response.jobId <= 0) {
        throw const FormatException('생성 작업의 jobId가 올바르지 않습니다.');
      }
      return Result.success(response.jobId);
    } on Exception catch (error) {
      return Result.failure(mapApiError(error));
    }
  }

  @override
  Future<Result<QuizSubmissionEntity>> submitQuiz({
    required int quizId,
    required List<QuizAnswerEntity> answers,
  }) async {
    try {
      final response = await _quizRemoteDataSource.submitQuiz(
        quizId: quizId,
        request: QuizSubmitModel(
          answers: answers.map((answer) => answer.toRequest()).toList(),
        ),
      );
      return Result.success(response.toEntity());
    } on Exception catch (error) {
      return Result.failure(mapApiError(error));
    }
  }

  @override
  Future<Result<QuizEntity>> getQuiz({required int quizId}) async {
    try {
      final response = await _quizRemoteDataSource.getQuiz(quizId: quizId);
      return Result.success(response.toEntity());
    } on Exception catch (error) {
      return Result.failure(mapApiError(error));
    }
  }

  @override
  Future<Result<int>> requestMaterialQuizGeneration({
    required int materialId,
    required QuizGenerationOptionsEntity options,
  }) async {
    try {
      final response = await _quizRemoteDataSource.getJobIdByOptions(
        materialId: materialId,
        options: options.toRequest(),
      );
      if (response.jobId <= 0) {
        throw const FormatException('생성 작업의 jobId가 올바르지 않습니다.');
      }
      return Result.success(response.jobId);
    } on Exception catch (error) {
      return Result.failure(mapApiError(error));
    }
  }

  @override
  Future<Result<int>> uploadFile({
    required List<int> fileBytes,
    required String fileName,
    required QuizGenerationOptionsEntity options,
    String? title,
  }) async {
    try {
      final materialId = await _quizRemoteDataSource.getMaterialIdByPdf(
        file: MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
          contentType: DioMediaType('application', 'pdf'),
        ),
        title: title,
      );

      final jobId = await _quizRemoteDataSource.getJobIdByOptions(
        materialId: materialId.materialId,
        options: options.toRequest(),
      );

      return Result.success(jobId.jobId);
    } on Exception catch (error) {
      return Result.failure(mapApiError(error));
    }
  }

  @override
  Stream<Result<QuizGenerationJobEntity>> watchGenerationJob({
    required int jobId,
  }) async* {
    try {
      await for (final response in _quizRemoteDataSource.watchGenerationJob(
        jobId: jobId,
      )) {
        if (response.jobId != jobId) {
          throw const FormatException('작업 상태 응답의 jobId가 일치하지 않습니다.');
        }
        final job = response.toEntity();
        yield Result.success(job);
        if (job.status == QuizGenerationStatus.done ||
            job.status == QuizGenerationStatus.failed) {
          return;
        }
      }
      throw StateError('작업 완료 전에 SSE 연결이 종료되었습니다.');
    } catch (error) {
      yield Result.failure(
        error is Exception ? mapApiError(error) : Exception(error.toString()),
      );
    }
  }
}
