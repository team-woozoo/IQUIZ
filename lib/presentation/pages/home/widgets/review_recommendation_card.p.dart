part of '../home_page.dart';

class _ReviewRecommendationCard extends ConsumerWidget
    with HomeState, HomeEvent {
  const _ReviewRecommendationCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      weakConceptsAsync(ref).when(
        skipLoadingOnReload: false,
        skipLoadingOnRefresh: false,
        loading: () => const _ReviewRecommendationContent(loading: true),
        error: (_, _) => const _ReviewRecommendationContent(
          title: '복습할 개념을 불러오지 못했어요',
          message: '아래로 당겨 다시 시도해 주세요.',
        ),
        data: (concepts) {
          final concept = reviewConcept(concepts);
          if (concept == null) {
            return const _ReviewRecommendationContent(
              title: '아직 분석할 개념이 없어요',
              message: '퀴즈를 풀면 복습할 개념을 알려드려요',
            );
          }
          return _ReviewRecommendationContent(
            materialTitle: concept.materialTitle,
            title: reviewTitle(concept),
            message: '해당 개념을 다시 풀어볼까요?',
            onTap: () => onReviewRecommendationTapped(ref, concept),
          );
        },
      );
}
