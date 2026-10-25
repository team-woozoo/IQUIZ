part of '../home_page.dart';

class _GeneratingMaterialList extends ConsumerWidget with HomeState {
  const _GeneratingMaterialList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = generatingMaterials(ref);
    return SliverList.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) => _RecentMaterialContent(
        title: entries[index].title,
        subtitle: generationLabel(entries[index]),
        generating: true,
      ),
    );
  }
}
