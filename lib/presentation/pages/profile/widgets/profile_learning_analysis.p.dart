part of '../profile_page.dart';

class _ProfileLearningAnalysis extends ConsumerWidget {
  const _ProfileLearningAnalysis({required this.nickname});
  final String nickname;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scores = ref.watch(myCognitiveTypeScoresProvider);
    return ColoredBox(
      color: AppColor.surfaceSubtle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('나의 학습 분석', style: AppTextStyle.title3),
            const SizedBox(height: 2),
            Text(
              '$nickname님의 문제 유형별 정답률을 표시해요',
              style: AppTextStyle.reqular(
                14,
                20.3,
              ).copyWith(color: AppColor.secondaryText),
            ),
            const SizedBox(height: 24),
            scores.when(
              skipLoadingOnReload: false,
              skipLoadingOnRefresh: false,
              data: (items) => _ProfileScoreChart(scores: items),
              loading: () => const SizedBox(
                height: 272,
                child: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: '학습 분석을 불러오는 중이에요',
                  ),
                ),
              ),
              error: (_, _) => SizedBox(
                height: 272,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '학습 분석을 불러오지 못했어요',
                        style: AppTextStyle.medium(16, 22.4),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(myCognitiveTypeScoresProvider),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 31),
            FilledButton(
              key: const ValueKey('profile_fill_weaknesses'),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                useSafeArea: true,
                isScrollControlled: true,
                backgroundColor: AppColor.white,
                builder: (_) => const _ProfileWeakConceptsSheet(),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColor.primaryAction,
                foregroundColor: AppColor.white,
                minimumSize: const Size.fromHeight(44),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTextStyle.btn1,
              ),
              child: const Text('나의 약한 부분 채우기', textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
