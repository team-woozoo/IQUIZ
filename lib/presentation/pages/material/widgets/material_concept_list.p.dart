part of '../material_detail_page.dart';

class _MaterialConceptList extends ConsumerWidget with MaterialDetailState {
  const _MaterialConceptList({required this.materialId});

  final int materialId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(myMaterialConceptsProvider(materialId: materialId))
      .when(
        skipLoadingOnReload: false,
        loading: () => const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
        error: (error, _) => SliverToBoxAdapter(
          child: _MaterialMessage(
            message: materialError(error),
            onRetry: () => ref.invalidate(
              myMaterialConceptsProvider(materialId: materialId),
            ),
          ),
        ),
        data: (items) => items.isEmpty
            ? const SliverToBoxAdapter(
                child: _MaterialMessage(message: '아직 분석할 개념이 없어요.'),
              )
            : SliverList.builder(
                itemCount: items.length,
                itemBuilder: (_, index) =>
                    _MaterialConceptTile(concept: items[index]),
              ),
      );
}

class _MaterialConceptTile extends StatelessWidget with MaterialDetailState {
  const _MaterialConceptTile({required this.concept});
  final MaterialConceptEntity concept;

  @override
  Widget build(BuildContext context) {
    final (label, foreground, background) = switch (concept.status) {
      MaterialConceptState.weak => (
        '부족해요',
        AppColor.danger,
        AppColor.dangerSubtle,
      ),
      MaterialConceptState.good => (
        '보통',
        AppColor.brandColor,
        AppColor.splashBackground,
      ),
      MaterialConceptState.perfect => (
        '완벽해요',
        AppColor.success,
        AppColor.successSubtle,
      ),
      MaterialConceptState.unchecked => (
        '정보가 없어요',
        AppColor.secondaryText,
        AppColor.neutralSubtle,
      ),
    };
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColor.divider)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      concept.conceptName,
                      style: AppTextStyle.medium(16, 22.4),
                    ),
                    Text(
                      '${concept.questionCount}문제',
                      style: AppTextStyle.reqular(
                        13,
                        18.2,
                      ).copyWith(color: AppColor.tertiaryText),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  pageLabel(concept.pageNos),
                  style: AppTextStyle.reqular(
                    14,
                    19.6,
                  ).copyWith(color: AppColor.secondaryText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: AppTextStyle.medium(13, 18.2).copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
