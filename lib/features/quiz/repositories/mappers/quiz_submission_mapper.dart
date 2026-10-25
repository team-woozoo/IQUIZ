import 'package:iquiz/features/quiz/data_source/remote/models/quiz_answer_model.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/quiz_submit_result_model.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_question_result_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_submission_entity.dart';

extension QuizAnswerMapper on QuizAnswerEntity {
  QuizAnswerModel toRequest() =>
      QuizAnswerModel(questionId: questionId, optionId: optionId);
}

extension QuizSubmitResultMapper on QuizSubmitResultModel {
  QuizSubmissionEntity toEntity() {
    if (submissionId <= 0 ||
        totalCount <= 0 ||
        correctCount < 0 ||
        correctCount > totalCount ||
        results.length != totalCount ||
        results.any((result) => result.questionId <= 0) ||
        results.map((result) => result.questionId).toSet().length !=
            totalCount ||
        results.where((result) => result.correct).length != correctCount) {
      throw const FormatException('서버 채점 결과가 올바르지 않습니다.');
    }
    return QuizSubmissionEntity(
      submissionId: submissionId,
      correctCount: correctCount,
      totalCount: totalCount,
      results: List.unmodifiable(
        results.map(
          (result) => QuizQuestionResultEntity(
            questionId: result.questionId,
            correct: result.correct,
          ),
        ),
      ),
    );
  }
}
