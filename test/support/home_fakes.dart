import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/features/auth/repositories/entities/user_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_last_submission_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_summary_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/study_material_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_difficulty.enum.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_format.enum.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';

const homeUser = UserEntity(id: 42, email: 'quiz@example.com', nickname: '퀴즈');

StudyMaterialEntity homeMaterial({
  int id = 1,
  String title = '운영체제 핵심 정리',
  bool generating = false,
  int answeredCount = 10,
}) => StudyMaterialEntity(
  materialId: id,
  title: title,
  originalFilename: 'material.pdf',
  pageCount: 12,
  createdAt: DateTime.utc(2026, 10, 19),
  questionCount: 10,
  answeredCount: answeredCount,
  correctCount: answeredCount < 8 ? answeredCount : 8,
  wrongCount: 10 - (answeredCount < 8 ? answeredCount : 8),
  accuracy: answeredCount == 0
      ? null
      : (answeredCount < 8 ? answeredCount : 8) / 10,
  generating: generating,
);

class HomeTestAuth extends UserAuth {
  @override
  UserAuthState build() =>
      const UserAuthState(AuthStatus.authenticated, user: homeUser);

  void setUser(UserEntity? user) {
    state = UserAuthState(
      user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated,
      user: user,
    );
  }

  @override
  Future<Result<void>> signOut() async {
    setUser(null);
    return Result.success(null);
  }
}

QuizSummaryEntity homeQuiz({
  int quizId = 7,
  int? materialId = 1,
  String? title = '운영체제 핵심 정리',
  QuizLastSubmissionEntity? lastSubmission,
  int submissionCount = 0,
  DateTime? createdAt,
}) => QuizSummaryEntity(
  quizId: quizId,
  materialId: materialId,
  materialTitle: title,
  format: QuizFormat.multipleChoice,
  difficulty: QuizDifficulty.normal,
  questionCount: 10,
  createdAt: createdAt ?? DateTime.utc(2026, 10, 19),
  submissionCount: submissionCount,
  lastSubmission: lastSubmission,
);
