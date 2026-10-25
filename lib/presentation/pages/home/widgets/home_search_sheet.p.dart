part of '../home_page.dart';

class _HomeSearchSheet extends HookConsumerWidget with HomeState, HomeEvent {
  const _HomeSearchSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = useSearchState();
    final controller = search.controller;
    final query = search.query;
    final materials = materialsAsync(ref);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                controller: controller,
                autofocus: true,
                style: AppTextStyle.medium(16, 22.4),
                decoration: InputDecoration(
                  labelText: '자료 제목 검색',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: '검색어 지우기',
                          onPressed: () => onSearchCleared(controller),
                          icon: const Icon(Icons.close),
                        ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: materials.when(
                data: (items) {
                  final matches = matchingMaterials(items, query);
                  if (matches.isEmpty) {
                    return const Center(child: Text('검색 결과가 없어요.'));
                  }
                  return ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: matches.length,
                    itemBuilder: (context, index) => _RecentMaterialTile(
                      material: matches[index],
                      onTap: () =>
                          onSearchResultTapped(context, matches[index]),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => SingleChildScrollView(
                  child: _HomeListMessage(
                    icon: Icons.cloud_off_outlined,
                    title: '자료를 검색하지 못했어요',
                    message: '목록을 다시 불러온 뒤 검색해 주세요.',
                    actionLabel: '다시 시도',
                    onAction: () => onRetry(ref),
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
