import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/features/learning_profile/data_source/remote/learning_profile_remote_data_source.dart';
import 'package:iquiz/features/learning_profile/data_source/remote/learning_profile_remote_data_source_impl.dart';
import 'package:iquiz/features/learning_profile/repositories/learning_profile_repository.dart';
import 'package:iquiz/features/learning_profile/repositories/learning_profile_repository_impl.dart';
import 'package:iquiz/features/learning_profile/usecases/get_my_cognitive_type_scores_use_case.dart';
import 'package:iquiz/features/learning_profile/usecases/get_my_weak_concepts_use_case.dart';

final learningProfileRemoteDataSourceProvider =
    Provider<LearningProfileRemoteDataSource>((ref) {
      return const LearningProfileRemoteDataSourceImpl();
    });

final learningProfileRepositoryProvider = Provider<LearningProfileRepository>((
  ref,
) {
  return LearningProfileRepositoryImpl(
    ref.watch(learningProfileRemoteDataSourceProvider),
  );
});

final getMyWeakConceptsUseCaseProvider = Provider<GetMyWeakConceptsUseCase>((
  ref,
) {
  return GetMyWeakConceptsUseCase(ref.watch(learningProfileRepositoryProvider));
});

final getMyCognitiveTypeScoresUseCaseProvider =
    Provider<GetMyCognitiveTypeScoresUseCase>((ref) {
      return GetMyCognitiveTypeScoresUseCase(
        ref.watch(learningProfileRepositoryProvider),
      );
    });
