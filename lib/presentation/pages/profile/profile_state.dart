part of 'profile_page.dart';

mixin class ProfileState {
  /// 프로필에 표시할 사용자 정보의 변경만 구독
  UserEntity? profileUser(WidgetRef ref) =>
      ref.watch(userAuthProvider.select((auth) => auth.user));

  /// 문제 인지 유형별 학습 분석의 데이터·로딩·오류 상태를 구독
  AsyncValue<List<CognitiveTypeScoreEntity>> scoresAsync(WidgetRef ref) =>
      ref.watch(myCognitiveTypeScoresProvider);

  /// 맞춤 복습에 사용할 약한 개념 목록의 비동기 상태를 구독
  AsyncValue<List<WeakConceptEntity>> weakConceptsAsync(WidgetRef ref) =>
      ref.watch(myWeakConceptsProvider);
}
