import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_summary_difficulty.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_summary_format.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/quiz_summary_model.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_last_submission_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_summary_entity.dart';

extension QuizSummaryMapper on QuizSummaryModel {
  QuizSummaryEntity toEntity() => QuizSummaryEntity(
    quizId: quizId,
    materialId: materialId,
    materialTitle: materialTitle,
    format: switch (format) {
      QuizSummaryFormat.multipleChoice => .multipleChoice,
      QuizSummaryFormat.ox => .ox,
      QuizSummaryFormat.$unknown => throw const FormatException(
        '지원하지 않는 문제 형식입니다.',
      ),
    },
    difficulty: switch (difficulty) {
      QuizSummaryDifficulty.easy => .easy,
      QuizSummaryDifficulty.normal => .normal,
      QuizSummaryDifficulty.hard => .hard,
      QuizSummaryDifficulty.$unknown => throw const FormatException(
        '지원하지 않는 난이도입니다.',
      ),
    },
    questionCount: questionCount,
    createdAt: createdAt,
    submissionCount: submissionCount,
    lastSubmission: lastSubmission == null
        ? null
        : QuizLastSubmissionEntity(
            correctCount: lastSubmission!.correctCount,
            submittedAt: lastSubmission!.submittedAt,
          ),
  );
}
