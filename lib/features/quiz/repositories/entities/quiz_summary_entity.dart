import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_summary_difficulty.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_summary_format.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/quiz_summary_model.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_last_submission_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_difficulty.enum.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_format.enum.dart';

final class QuizSummaryEntity {
  const QuizSummaryEntity({
    required this.quizId,
    this.materialId,
    required this.materialTitle,
    required this.format,
    required this.difficulty,
    required this.questionCount,
    required this.createdAt,
    required this.submissionCount,
    required this.lastSubmission,
  });

  factory QuizSummaryEntity.fromModel(QuizSummaryModel model) =>
      QuizSummaryEntity(
        quizId: model.quizId,
        materialId: model.materialId,
        materialTitle: model.materialTitle,
        format: switch (model.format) {
          QuizSummaryFormat.multipleChoice => .multipleChoice,
          QuizSummaryFormat.ox => .ox,
          QuizSummaryFormat.$unknown => throw const FormatException(
            '지원하지 않는 문제 형식입니다.',
          ),
        },
        difficulty: switch (model.difficulty) {
          QuizSummaryDifficulty.easy => .easy,
          QuizSummaryDifficulty.normal => .normal,
          QuizSummaryDifficulty.hard => .hard,
          QuizSummaryDifficulty.$unknown => throw const FormatException(
            '지원하지 않는 난이도입니다.',
          ),
        },
        questionCount: model.questionCount,
        createdAt: model.createdAt,
        submissionCount: model.submissionCount,
        lastSubmission: model.lastSubmission == null
            ? null
            : QuizLastSubmissionEntity.fromModel(model.lastSubmission!),
      );

  final int quizId;
  final int? materialId;
  final String? materialTitle;
  final QuizFormat format;
  final QuizDifficulty difficulty;
  final int questionCount;
  final DateTime createdAt;
  final int submissionCount;
  final QuizLastSubmissionEntity? lastSubmission;
}
