import 'package:iquiz/features/quiz/usecases/request_weakness_quiz_generation_use_case.dart';
import 'package:iquiz/features/quiz/usecases/get_my_wrong_answers_use_case.dart';
import 'package:iquiz/features/quiz/usecases/submit_wrong_answer_review_use_case.dart';
import 'package:iquiz/features/quiz/usecases/get_my_material_concepts_use_case.dart';
import 'package:iquiz/features/quiz/usecases/get_my_material_use_case.dart';
import 'package:iquiz/features/quiz/usecases/get_my_materials_use_case.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/features/quiz/data_source/remote/quiz_remote_data_source.dart';
import 'package:iquiz/features/quiz/data_source/remote/quiz_remote_data_source_impl.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository_impl.dart';
import 'package:iquiz/features/quiz/usecases/get_quiz_use_case.dart';
import 'package:iquiz/features/quiz/usecases/get_my_quizzes_use_case.dart';
import 'package:iquiz/features/quiz/usecases/submit_quiz_use_case.dart';
import 'package:iquiz/features/quiz/usecases/upload_file_use_case.dart';
import 'package:iquiz/features/quiz/usecases/request_material_quiz_generation_use_case.dart';
import 'package:iquiz/features/quiz/usecases/watch_generation_job_use_case.dart';

final quizRemoteDataSourceProvider = Provider<QuizRemoteDataSource>((ref) {
  return const QuizRemoteDataSourceImpl();
});

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepositoryImpl(ref.watch(quizRemoteDataSourceProvider));
});

final getMyWrongAnswersUseCaseProvider = Provider<GetMyWrongAnswersUseCase>(
  (ref) => GetMyWrongAnswersUseCase(ref.watch(quizRepositoryProvider)),
);

final submitWrongAnswerReviewUseCaseProvider =
    Provider<SubmitWrongAnswerReviewUseCase>(
      (ref) =>
          SubmitWrongAnswerReviewUseCase(ref.watch(quizRepositoryProvider)),
    );

final getQuizUseCaseProvider = Provider<GetQuizUseCase>((ref) {
  return GetQuizUseCase(ref.watch(quizRepositoryProvider));
});

final getMyQuizzesUseCaseProvider = Provider<GetMyQuizzesUseCase>((ref) {
  return GetMyQuizzesUseCase(ref.watch(quizRepositoryProvider));
});

final submitQuizUseCaseProvider = Provider<SubmitQuizUseCase>((ref) {
  return SubmitQuizUseCase(ref.watch(quizRepositoryProvider));
});

final uploadFileUseCaseProvider = Provider<UploadFileUseCase>((ref) {
  return UploadFileUseCase(ref.watch(quizRepositoryProvider));
});

final requestMaterialQuizGenerationUseCaseProvider =
    Provider<RequestMaterialQuizGenerationUseCase>(
      (ref) => RequestMaterialQuizGenerationUseCase(
        ref.watch(quizRepositoryProvider),
      ),
    );

final watchGenerationJobUseCaseProvider = Provider<WatchGenerationJobUseCase>((
  ref,
) {
  return WatchGenerationJobUseCase(ref.watch(quizRepositoryProvider));
});

final getMyMaterialsUseCaseProvider = Provider<GetMyMaterialsUseCase>(
  (ref) => GetMyMaterialsUseCase(ref.watch(quizRepositoryProvider)),
);

final getMyMaterialUseCaseProvider = Provider<GetMyMaterialUseCase>(
  (ref) => GetMyMaterialUseCase(ref.watch(quizRepositoryProvider)),
);

final getMyMaterialConceptsUseCaseProvider =
    Provider<GetMyMaterialConceptsUseCase>(
      (ref) => GetMyMaterialConceptsUseCase(ref.watch(quizRepositoryProvider)),
    );

final requestWeaknessQuizGenerationUseCaseProvider =
    Provider<RequestWeaknessQuizGenerationUseCase>(
      (ref) => RequestWeaknessQuizGenerationUseCase(
        ref.watch(quizRepositoryProvider),
      ),
    );
