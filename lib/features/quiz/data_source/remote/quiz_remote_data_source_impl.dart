import 'package:dio/dio.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/wrong_answer_model.dart';
import 'package:iquiz/app/network/app_dio.dart';
import 'package:iquiz/core/helper/future_extension.dart';
import 'package:iquiz/core/helper/sse_extension.dart';
import 'package:iquiz/core/helper/stream_extenstion.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_job_status.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/quiz_generation_options_model.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/quiz_generation_task_model.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/quiz_generation_job_model.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/quiz_model.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/material_upload_result_model.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/quiz_submit_result_model.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/quiz_submit_model.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/quiz_summary_model.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/study_material_model.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/material_concept_model.dart';
import 'package:iquiz/features/quiz/data_source/remote/quiz_remote_data_source.dart';

final class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  const QuizRemoteDataSourceImpl();

  AppDio get _dio => AppDio.instance;

  @override
  Future<List<WrongAnswerModel>> getMyWrongAnswers() => _dio
      .get('/users/me/wrong-answers')
      .withListConverter(fromJson: WrongAnswerModel.fromJson);

  @override
  Future<QuizSubmitResultModel> submitWrongAnswerReview({
    required QuizSubmitModel request,
  }) => _dio
      .post('/users/me/wrong-answers/submissions', data: request.toJson())
      .withSingleConverter(fromJson: QuizSubmitResultModel.fromJson);

  @override
  Future<List<QuizSummaryModel>> getMyQuizzes({int? materialId}) => _dio
      .get('/quizzes', queryParameters: {'materialId': ?materialId})
      .withListConverter(fromJson: QuizSummaryModel.fromJson);

  @override
  Future<List<StudyMaterialModel>> getMyMaterials() => _dio
      .get('/materials')
      .withListConverter(fromJson: StudyMaterialModel.fromJson);

  @override
  Future<StudyMaterialModel> getMyMaterial({required int materialId}) async {
    final material = await _dio
        .get('/materials/$materialId')
        .withSingleConverter(fromJson: StudyMaterialModel.fromJson);
    if (material.materialId != materialId) {
      throw const FormatException('자료 응답의 materialId가 일치하지 않습니다.');
    }
    return material;
  }

  @override
  Future<List<MaterialConceptModel>> getMyMaterialConcepts({
    required int materialId,
  }) => _dio
      .get('/materials/$materialId/concepts')
      .withListConverter(fromJson: MaterialConceptModel.fromJson);

  @override
  Future<QuizGenerationTaskModel> requestWeaknessQuizGeneration({
    required int conceptId,
    required QuizGenerationOptionsModel options,
  }) => _dio
      .post('/concepts/$conceptId/quizzes', data: options.toJson())
      .withSingleConverter(fromJson: QuizGenerationTaskModel.fromJson);

  @override
  Future<QuizSubmitResultModel> submitQuiz({
    required int quizId,
    required QuizSubmitModel request,
  }) => _dio
      .post('/quizzes/$quizId/submissions', data: request.toJson())
      .withSingleConverter(fromJson: QuizSubmitResultModel.fromJson);

  @override
  Future<MaterialUploadResultModel> getMaterialIdByPdf({
    required MultipartFile file,
    String? title,
  }) => _dio
      .postMultipart(
        '/materials',
        data: FormData.fromMap({'file': file, 'title': ?title}),
      )
      .withSingleConverter(fromJson: MaterialUploadResultModel.fromJson);

  @override
  Future<QuizGenerationTaskModel> getJobIdByOptions({
    required int materialId,
    required QuizGenerationOptionsModel options,
  }) => _dio
      .post('/materials/$materialId/quizzes', data: options.toJson())
      .withSingleConverter(fromJson: QuizGenerationTaskModel.fromJson);

  @override
  Stream<QuizGenerationJobModel> watchGenerationJob({
    required int jobId,
  }) async* {
    final jobs = _dio
        .getSseJson('/jobs/$jobId/events', maxReconnectAttempts: 3)
        .withSingleConverter(fromJson: QuizGenerationJobModel.fromJson);

    await for (final job in jobs) {
      if (job.jobId != jobId) {
        throw const FormatException('작업 상태 응답의 jobId가 일치하지 않습니다.');
      }
      if (job.status == QuizJobStatus.done && job.quizId == null) {
        throw const FormatException('완료된 작업 응답에 quizId가 없습니다.');
      }

      yield job;
      if (job.status == QuizJobStatus.done ||
          job.status == QuizJobStatus.failed) {
        return;
      }
    }

    throw Exception('작업 상태 연결을 복구하지 못했습니다. 잠시 후 다시 시도해 주세요.');
  }

  @override
  Future<QuizModel> getQuiz({required int quizId}) async {
    final result = await _dio
        .get('/quizzes/$quizId')
        .withSingleConverter(fromJson: QuizModel.fromJson);
    if (result.quizId != quizId) {
      throw const FormatException('퀴즈 응답의 quizId가 일치하지 않습니다.');
    }

    return result;
  }
}
