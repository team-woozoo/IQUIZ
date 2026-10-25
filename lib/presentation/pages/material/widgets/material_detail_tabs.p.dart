part of '../material_detail_page.dart';

class _MaterialDetailTabs extends StatelessWidget {
  const _MaterialDetailTabs({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColor.segmentedBackground,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        for (var index = 0; index < 2; index++)
          Expanded(
            child: Semantics(
              selected: selected == index,
              button: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: selected == index ? AppColor.white : null,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: selected == index
                      ? const [
                          BoxShadow(
                            color: Color(0x1F000000),
                            offset: Offset(0, 2),
                            blurRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: ValueKey('material_tab_$index'),
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => onSelected(index),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 36),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      alignment: Alignment.center,
                      child: Text(
                        index == 0 ? '분석' : '기록',
                        style: selected == index
                            ? AppTextStyle.semiBold(15, 21.75)
                            : AppTextStyle.medium(
                                15,
                                21.75,
                              ).copyWith(color: AppColor.secondaryText),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
