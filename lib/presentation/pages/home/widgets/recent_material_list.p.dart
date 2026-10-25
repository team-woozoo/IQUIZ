part of '../home_page.dart';

class _RecentMaterialList extends HookConsumerWidget with HomeState, HomeEvent {
  const _RecentMaterialList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opening = useState(false);
    final hasGeneratingMaterials = generatingMaterials(ref).isNotEmpty;
    return materialsAsync(ref).when(
      skipLoadingOnReload: false,
      data: (items) => items.isEmpty && hasGeneratingMaterials
          ? const SliverToBoxAdapter(child: SizedBox.shrink())
          : items.isEmpty
          ? SliverToBoxAdapter(
              child: _HomeListMessage(
                icon: Icons.quiz_outlined,
                title: '아직 올린 자료가 없어요',
                message: '학습 자료를 올려 첫 퀴즈를 만들어 보세요.',
                actionLabel: '첫 퀴즈 만들기',
                onAction: () => onUploadTapped(context),
              ),
            )
          : SliverList.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => _RecentMaterialTile(
                key: ValueKey(items[index].materialId),
                material: items[index],
                onTap: () => onMaterialTapped(ref, items[index], opening),
              ),
            ),
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Center(
            child: CircularProgressIndicator(color: AppColor.brandColor),
          ),
        ),
      ),
      error: (error, _) => SliverToBoxAdapter(
        child: _HomeListMessage(
          icon: Icons.cloud_off_outlined,
          title: '자료 목록을 불러오지 못했어요',
          message: quizListError(error),
          actionLabel: '다시 시도',
          onAction: () => onRetry(ref),
        ),
      ),
    );
  }
}
