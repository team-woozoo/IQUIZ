import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/quiz/repositories/entities/wrong_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_job_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_options_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_submission_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_summary_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/study_material_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/material_concept_entity.dart';

abstract interface class QuizRepository {
  /// 미해결 오답을 처음 틀린 순서로 조회
  /// 문제의 정답·해설·원본 자료와 오답 횟수를 함께 반환
  Future<Result<List<WrongAnswerEntity>>> getMyWrongAnswers();

  /// 복습한 [answers]를 채점하고 문제별 정오답과 정답 수를 반환
  /// 여러 퀴즈의 문제를 함께 제출할 수 있으며 퀴즈별 풀이 기록은 변경하지 않음
  /// 같은 답안도 다시 제출하면 별도로 기록
  Future<Result<QuizSubmissionEntity>> submitWrongAnswerReview({
    required List<QuizAnswerEntity> answers,
  });

  /// [fileBytes]와 [fileName]으로 PDF를 업로드하고 [options]에 따라 퀴즈 생성을 요청
  /// 선택적으로 자료 [title]을 지정하며, 생성 진행 상황을 조회할 jobId를 반환
  Future<Result<int>> uploadFile({
    required List<int> fileBytes,
    required String fileName,
    required QuizGenerationOptionsEntity options,
    String? title,
  });

  /// 기존 [materialId]로 PDF 재업로드 없이 퀴즈를 생성하고 jobId를 반환
  Future<Result<int>> requestMaterialQuizGeneration({
    required int materialId,
    required QuizGenerationOptionsEntity options,
  });

  /// [jobId]에 해당하는 퀴즈 생성 진행 상황을 SSE로 구독
  /// 생성 완료 또는 실패 상태를 전달한 뒤 구독을 종료
  Stream<Result<QuizGenerationJobEntity>> watchGenerationJob({
    required int jobId,
  });

  /// [quizId]에 해당하는 퀴즈의 문제·보기·정답·해설을 조회
  Future<Result<QuizEntity>> getQuiz({required int quizId});

  /// 내 학습 자료를 최근 업로드 순으로 조회하며 학습 집계와 생성 중 상태를 함께 반환
  Future<Result<List<StudyMaterialEntity>>> getMyMaterials();

  /// [materialId]에 해당하는 내 자료의 기본 정보와 전체 문제 기준 학습 집계를 조회
  Future<Result<StudyMaterialEntity>> getMyMaterial({required int materialId});

  /// [materialId]에 해당하는 내 자료의 개념별 페이지·학습 집계·상태를 조회
  /// 서버가 정한 개념 순서를 유지
  Future<Result<List<MaterialConceptEntity>>> getMyMaterialConcepts({
    required int materialId,
  });

  /// 내 퀴즈 목록과 최근 풀이 기록을 최근 생성 순으로 조회
  /// [materialId]를 지정하면 해당 자료의 퀴즈만, 생략하면 전체 퀴즈를 반환
  Future<Result<List<QuizSummaryEntity>>> getMyQuizzes({int? materialId});

  /// [conceptId]가 나온 페이지로 [options]에 따른 약점 퀴즈 생성을 요청
  /// 생성 진행 상황을 조회할 jobId를 반환
  Future<Result<int>> requestWeaknessQuizGeneration({
    required int conceptId,
    required QuizGenerationOptionsEntity options,
  });

  /// [quizId]에 해당하는 퀴즈의 [answers]를 제출하고 채점 결과를 반환
  /// 제출 결과는 퀴즈별 풀이 기록과 학습 통계에 반영
  Future<Result<QuizSubmissionEntity>> submitQuiz({
    required int quizId,
    required List<QuizAnswerEntity> answers,
  });
}
