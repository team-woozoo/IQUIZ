part of '../home_page.dart';

class _HomeContent extends BasePage with HomeEvent {
  const _HomeContent();

  @override
  PreferredSizeWidget buildAppBar(BuildContext context, WidgetRef ref) =>
      const _HomeAppBar();

  @override
  bool get wrapWithSafeArea => false;

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: RefreshIndicator(
          color: AppColor.brandColor,
          onRefresh: () => onRefresh(ref),
          child: CustomScrollView(
            key: const PageStorageKey('home_quizzes'),
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(child: _ReviewRecommendationCard()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 31, 16, 16),
                sliver: SliverToBoxAdapter(
                  child: Text('최근 자료', style: AppTextStyle.title3),
                ),
              ),
              const _GeneratingMaterialList(),
              const _RecentMaterialList(),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
