part of '../material_detail_page.dart';

class _MaterialQuizSelectionSheet extends HookConsumerWidget
    with MaterialDetailState {
  const _MaterialQuizSelectionSheet({required this.material});

  final StudyMaterialEntity material;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selecting = useRef(false);
    final quizzes = ref.watch(
      materialQuizzesProvider(materialId: material.materialId),
    );
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('풀 퀴즈 선택', style: AppTextStyle.title1),
                  const SizedBox(height: 8),
                  Text(
                    material.title,
                    style: AppTextStyle.reqular(
                      15,
                      21.75,
                    ).copyWith(color: AppColor.secondaryText),
                  ),
                ],
              ),
            ),
            Expanded(
              child: quizzes.when(
                skipLoadingOnReload: false,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _MaterialMessage(
                  message: materialError(error),
                  onRetry: () => ref.invalidate(
                    materialQuizzesProvider(materialId: material.materialId),
                  ),
                ),
                data: (items) => items.isEmpty
                    ? const _MaterialMessage(message: '아직 생성한 퀴즈가 없어요.')
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) => _MaterialHistoryTile(
                          quiz: items[index],
                          onTap: () {
                            if (selecting.value) return;
                            selecting.value = true;
                            Navigator.of(context).pop(items[index].quizId);
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
