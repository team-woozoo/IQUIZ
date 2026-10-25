part of '../profile_page.dart';

class _ProfileWeakConceptsSheet extends ConsumerWidget {
  const _ProfileWeakConceptsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) => SizedBox(
    height: MediaQuery.sizeOf(context).height * 0.65,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('나의 약한 부분 채우기', style: AppTextStyle.title2),
              const SizedBox(height: 8),
              Text(
                '복습할 개념을 고르면 맞춤 문제 5개를 만들어요',
                style: AppTextStyle.reqular(
                  14,
                  20.3,
                ).copyWith(color: AppColor.secondaryText),
              ),
            ],
          ),
        ),
        Expanded(
          child: ref
              .watch(myWeakConceptsProvider)
              .when(
                skipLoadingOnReload: false,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('약한 개념을 불러오지 못했어요'),
                      TextButton(
                        onPressed: () => ref.invalidate(myWeakConceptsProvider),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
                data: (items) => items.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            '아직 복습할 개념이 없어요.\n퀴즈를 풀면 약한 개념을 알려드려요.',
                            textAlign: TextAlign.center,
                            style: AppTextStyle.medium(16, 22.4),
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: AppColor.divider),
                        itemBuilder: (_, index) {
                          final concept = items[index];
                          return ListTile(
                            key: ValueKey(
                              'profile_weak_concept_${concept.conceptId}',
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              concept.conceptName,
                              style: AppTextStyle.medium(16, 22.4),
                            ),
                            subtitle: Text(
                              '${concept.materialTitle} · 정답률 ${(concept.accuracy * 100).round()}%',
                              style: AppTextStyle.reqular(
                                14,
                                20.3,
                              ).copyWith(color: AppColor.secondaryText),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              final router = GoRouter.of(context);
                              Navigator.of(context).pop();
                              unawaited(
                                router.push<void>(
                                  UploadRoute(
                                    conceptId: concept.conceptId,
                                    conceptName: concept.conceptName,
                                  ).location,
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
        ),
      ],
    ),
  );
}
