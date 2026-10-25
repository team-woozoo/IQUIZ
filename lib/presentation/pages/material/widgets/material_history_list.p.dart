part of '../material_detail_page.dart';

class _MaterialHistoryList extends ConsumerWidget
    with MaterialDetailState, MaterialDetailEvent {
  const _MaterialHistoryList({required this.materialId});
  final int materialId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(materialQuizzesProvider(materialId: materialId))
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
            onRetry: () =>
                ref.invalidate(materialQuizzesProvider(materialId: materialId)),
          ),
        ),
        data: (items) => items.isEmpty
            ? const SliverToBoxAdapter(
                child: _MaterialMessage(message: '아직 생성한 퀴즈가 없어요.'),
              )
            : SliverList.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => _MaterialHistoryTile(
                  quiz: items[index],
                  onTap: () => onQuizTapped(
                    context,
                    items[index].quizId,
                    title: items[index].materialTitle,
                  ),
                ),
              ),
      );
}

class _MaterialHistoryTile extends StatelessWidget with MaterialDetailState {
  const _MaterialHistoryTile({required this.quiz, required this.onTap});
  final QuizSummaryEntity quiz;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final correct = quiz.lastSubmission?.correctCount;
    final isWeak =
        correct != null &&
        quiz.questionCount > 0 &&
        correct / quiz.questionCount < 0.6;
    return Material(
      color: AppColor.white,
      child: InkWell(
        key: ValueKey('material_quiz_${quiz.quizId}'),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColor.divider)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      historyDate(quiz.createdAt),
                      style: AppTextStyle.medium(16, 22.4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${quiz.format == QuizFormat.multipleChoice ? '객관식' : 'OX'} · ${quiz.questionCount}문제',
                      style: AppTextStyle.reqular(
                        14,
                        20.3,
                      ).copyWith(color: AppColor.secondaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: correct == null ? '–' : '$correct',
                      style: TextStyle(
                        color: isWeak ? AppColor.danger : AppColor.dark,
                      ),
                    ),
                    TextSpan(
                      text: ' / ${quiz.questionCount}',
                      style: const TextStyle(color: AppColor.disabledText),
                    ),
                  ],
                ),
                style: AppTextStyle.medium(18, 25.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
