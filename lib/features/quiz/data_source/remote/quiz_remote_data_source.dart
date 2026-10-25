import 'package:dio/dio.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/wrong_answer_model.dart';
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

abstract interface class QuizRemoteDataSource {
  Future<List<WrongAnswerModel>> getMyWrongAnswers();

  /// 중복 호출은 별도 풀이로 기록되므로 자동 재전송하지 않음
  Future<QuizSubmitResultModel> submitWrongAnswerReview({
    required QuizSubmitModel request,
  });

  /// PDF를 업로드하고 MaterialId 반환
  Future<MaterialUploadResultModel> getMaterialIdByPdf({
    required MultipartFile file,
    String? title,
  });

  /// MaterialId, GenerateQuizRequest를 기반으로 JobId 반환
  Future<QuizGenerationTaskModel> getJobIdByOptions({
    required int materialId,
    required QuizGenerationOptionsModel options,
  });

  /// JobId별 SSE 작업 상태를 구독하여 QuizGenerationJobModel 상태 반환
  Stream<QuizGenerationJobModel> watchGenerationJob({required int jobId});

  /// quizId별 생성된 QuizModel 반환
  Future<QuizModel> getQuiz({required int quizId});

  Future<List<StudyMaterialModel>> getMyMaterials();

  Future<StudyMaterialModel> getMyMaterial({required int materialId});

  Future<List<MaterialConceptModel>> getMyMaterialConcepts({
    required int materialId,
  });

  Future<List<QuizSummaryModel>> getMyQuizzes({int? materialId});

  Future<QuizGenerationTaskModel> requestWeaknessQuizGeneration({
    required int conceptId,
    required QuizGenerationOptionsModel options,
  });

  Future<QuizSubmitResultModel> submitQuiz({
    required int quizId,
    required QuizSubmitModel request,
  });
}
