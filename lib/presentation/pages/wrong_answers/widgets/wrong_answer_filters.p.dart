part of '../wrong_answers_page.dart';

class _WrongAnswerFilters extends StatelessWidget {
  const _WrongAnswerFilters({
    required this.materials,
    required this.materialId,
    required this.onSelected,
  });
  final Map<int, String> materials;
  final int? materialId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedId = materials.containsKey(materialId) ? materialId : null;
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _chip(null, '전체', selectedId == null),
            for (final material in materials.entries) ...[
              const SizedBox(width: 8),
              _chip(material.key, material.value, selectedId == material.key),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(int? id, String title, bool selected) => Semantics(
    selected: selected,
    button: true,
    child: Material(
      color: selected ? AppColor.dark : AppColor.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        key: ValueKey('wrong_answer_filter_${id ?? 'all'}'),
        borderRadius: BorderRadius.circular(999),
        onTap: () => onSelected(id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style:
                (selected
                        ? AppTextStyle.semiBold(14, 19.6)
                        : AppTextStyle.medium(14, 19.6))
                    .copyWith(
                      color: selected ? AppColor.white : AppColor.secondaryText,
                    ),
          ),
        ),
      ),
    ),
  );
}
