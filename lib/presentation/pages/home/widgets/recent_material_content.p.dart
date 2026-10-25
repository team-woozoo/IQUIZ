part of '../home_page.dart';

class _RecentMaterialContent extends StatelessWidget {
  const _RecentMaterialContent({
    required this.title,
    required this.subtitle,
    this.generating = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final bool generating;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColor.white,
    child: InkWell(
      onTap: onTap,
      hoverColor: AppColor.surfaceSubtle,
      highlightColor: AppColor.surfaceSubtle,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColor.splashBackground),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset('assets/home/pdf.svg'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.medium(16, 16 * 1.4),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyle.reqular(14, 14 * 1.4).copyWith(
                      color: generating
                          ? AppColor.brandColor
                          : AppColor.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ExcludeSemantics(
              child: SvgPicture.asset(
                generating
                    ? 'assets/home/chevron_right_disabled.svg'
                    : 'assets/home/chevron_right.svg',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
