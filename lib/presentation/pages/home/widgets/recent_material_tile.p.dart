part of '../home_page.dart';

class _RecentMaterialTile extends StatelessWidget with HomeState {
  const _RecentMaterialTile({
    super.key,
    required this.material,
    required this.onTap,
  });

  final StudyMaterialEntity material;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _RecentMaterialContent(
    title: material.title,
    subtitle: material.generating ? '문제 만드는 중...' : createdDate(material),
    generating: material.generating,
    onTap: onTap,
  );
}
