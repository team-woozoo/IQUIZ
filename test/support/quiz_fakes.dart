import 'package:iquiz/features/quiz/repositories/entities/study_material_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/wrong_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/material_concept_entity.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_job_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_options_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_option_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_question_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_question_result_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_submission_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_summary_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_difficulty.enum.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_format.enum.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository.dart';

const testQuiz = QuizEntity(
  quizId: 7,
  materialId: 1,
  format: QuizFormat.multipleChoice,
  difficulty: QuizDifficulty.normal,
  questions: [
    QuizQuestionEntity(
      questionId: 101,
      content: '첫 번째 문제',
      conceptName: '개념 하나',
      explanation: '첫 번째 해설',
      sourceQuote: '첫 번째 근거',
      sourcePageNo: 1,
      options: [
        QuizOptionEntity(optionId: 1001, content: '보기 A', isCorrect: true),
        QuizOptionEntity(optionId: 1002, content: '보기 B', isCorrect: false),
      ],
    ),
    QuizQuestionEntity(
      questionId: 102,
      content: '두 번째 문제',
      conceptName: '개념 둘',
      explanation: '두 번째 해설',
      sourceQuote: '',
      sourcePageNo: null,
      options: [
        QuizOptionEntity(optionId: 2001, content: '보기 C', isCorrect: false),
        QuizOptionEntity(optionId: 2002, content: '보기 D', isCorrect: true),
      ],
    ),
  ],
);

const testAnswers = [
  QuizAnswerEntity(questionId: 101, optionId: 1002),
  QuizAnswerEntity(questionId: 102, optionId: 2002),
];

const testSubmission = QuizSubmissionEntity(
  submissionId: 500,
  correctCount: 1,
  totalCount: 2,
  results: [
    QuizQuestionResultEntity(questionId: 101, correct: false),
    QuizQuestionResultEntity(questionId: 102, correct: true),
  ],
);

class FakeQuizRepository implements QuizRepository {
  final materialGenerationRequests = <int>[];
  QuizGenerationOptionsEntity? materialGenerationOptions;
  Future<Result<int>> Function()? onMaterialGeneration;
  int uploadRequests = 0;
  final weaknessGenerationRequests = <int>[];
  QuizGenerationOptionsEntity? weaknessGenerationOptions;

  @override
  Future<Result<int>> requestMaterialQuizGeneration({
    required int materialId,
    required QuizGenerationOptionsEntity options,
  }) async {
    materialGenerationRequests.add(materialId);
    materialGenerationOptions = options;
    return onMaterialGeneration == null
        ? Result.success(11)
        : await onMaterialGeneration!();
  }

  QuizEntity quiz = testQuiz;
  List<WrongAnswerEntity> wrongAnswers = [];
  int wrongAnswerReviewCount = 0;
  List<QuizAnswerEntity>? reviewedAnswers;
  Future<Result<QuizSubmissionEntity>> Function()? onSubmitWrongAnswerReview;

  @override
  Future<Result<List<WrongAnswerEntity>>> getMyWrongAnswers() async =>
      Result.success(wrongAnswers);

  @override
  Future<Result<QuizSubmissionEntity>> submitWrongAnswerReview({
    required List<QuizAnswerEntity> answers,
  }) async {
    wrongAnswerReviewCount++;
    reviewedAnswers = List.of(answers);
    return onSubmitWrongAnswerReview == null
        ? Result.success(testSubmission)
        : await onSubmitWrongAnswerReview!();
  }

  List<StudyMaterialEntity> materials = [];
  Map<int, List<MaterialConceptEntity>> concepts = {};
  int materialsCount = 0;
  final materialDetailRequests = <int>[];
  final conceptRequests = <int>[];
  final quizMaterialFilters = <int?>[];
  Future<Result<StudyMaterialEntity>> Function(int)? onGetMyMaterial;
  Future<Result<List<StudyMaterialEntity>>> Function()? onGetMyMaterials;
  Future<Result<List<MaterialConceptEntity>>> Function(int)?
  onGetMyMaterialConcepts;

  @override
  Future<Result<List<StudyMaterialEntity>>> getMyMaterials() async {
    materialsCount++;
    return onGetMyMaterials == null
        ? Result.success(materials)
        : await onGetMyMaterials!();
  }

  @override
  Future<Result<StudyMaterialEntity>> getMyMaterial({
    required int materialId,
  }) async {
    materialDetailRequests.add(materialId);
    return onGetMyMaterial == null
        ? Result.success(
            materials.firstWhere((item) => item.materialId == materialId),
          )
        : await onGetMyMaterial!(materialId);
  }

  @override
  Future<Result<List<MaterialConceptEntity>>> getMyMaterialConcepts({
    required int materialId,
  }) async {
    conceptRequests.add(materialId);
    return onGetMyMaterialConcepts == null
        ? Result.success(concepts[materialId] ?? [])
        : await onGetMyMaterialConcepts!(materialId);
  }

  @override
  Future<Result<int>> requestWeaknessQuizGeneration({
    required int conceptId,
    required QuizGenerationOptionsEntity options,
  }) {
    weaknessGenerationRequests.add(conceptId);
    weaknessGenerationOptions = options;
    return onUpload?.call() ?? (throw UnimplementedError());
  }

  int submitCount = 0;
  int myQuizzesCount = 0;
  List<QuizSummaryEntity> quizzes = [];
  List<QuizAnswerEntity>? submittedAnswers;
  Future<Result<QuizSubmissionEntity>> Function()? onSubmit;
  Future<Result<List<QuizSummaryEntity>>> Function()? onGetMyQuizzes;
  Future<Result<int>> Function()? onUpload;
  Stream<Result<QuizGenerationJobEntity>> Function()? onWatchGeneration;

  @override
  Future<Result<QuizEntity>> getQuiz({required int quizId}) async =>
      Result.success(quiz);

  @override
  Future<Result<QuizSubmissionEntity>> submitQuiz({
    required int quizId,
    required List<QuizAnswerEntity> answers,
  }) async {
    submitCount++;
    submittedAnswers = List.of(answers);
    return onSubmit == null
        ? Result.success(testSubmission)
        : await onSubmit!();
  }

  @override
  Future<Result<List<QuizSummaryEntity>>> getMyQuizzes({
    int? materialId,
  }) async {
    quizMaterialFilters.add(materialId);
    myQuizzesCount++;
    return onGetMyQuizzes == null
        ? Result.success(
            materialId == null
                ? quizzes
                : quizzes
                      .where((quiz) => quiz.materialId == materialId)
                      .toList(),
          )
        : await onGetMyQuizzes!();
  }

  @override
  Future<Result<int>> uploadFile({
    required List<int> fileBytes,
    required String fileName,
    required QuizGenerationOptionsEntity options,
    String? title,
  }) {
    uploadRequests++;
    return onUpload?.call() ?? (throw UnimplementedError());
  }

  @override
  Stream<Result<QuizGenerationJobEntity>> watchGenerationJob({
    required int jobId,
  }) => onWatchGeneration?.call() ?? (throw UnimplementedError());
}
