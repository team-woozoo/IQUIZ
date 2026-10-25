import 'package:iquiz/app/network/app_dio.dart';
import 'package:iquiz/core/helper/future_extension.dart';
import 'package:iquiz/features/learning_profile/data_source/remote/learning_profile_remote_data_source.dart';
import 'package:iquiz/features/learning_profile/data_source/remote/models/cognitive_type_score_model.dart';
import 'package:iquiz/features/learning_profile/data_source/remote/models/weak_concept_model.dart';

final class LearningProfileRemoteDataSourceImpl
    implements LearningProfileRemoteDataSource {
  const LearningProfileRemoteDataSourceImpl();

  AppDio get _dio => AppDio.instance;

  @override
  Future<List<WeakConceptModel>> getMyWeakConcepts() => _dio
      .get('/users/me/weak-concepts')
      .withListConverter(fromJson: WeakConceptModel.fromJson);

  @override
  Future<List<CognitiveTypeScoreModel>> getMyCognitiveTypeScores() => _dio
      .get('/users/me/cognitive-type-scores')
      .withListConverter(fromJson: CognitiveTypeScoreModel.fromJson);
}
