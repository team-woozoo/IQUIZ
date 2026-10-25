part of '../notice_page.dart';

class _NoticeHeader extends StatelessWidget {
  const _NoticeHeader({required this.config});
  final ConfigEntity config;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            config.title,
            style: AppTextStyle.headline3.copyWith(color: AppColor.dark),
          ),
          const SizedBox(height: 4),
          Text(
            config.description,
            style: AppTextStyle.body1.copyWith(
              color: AppColor.secondaryText,
              fontWeight: .w400,
            ),
          ),
          const Gap(12),
          Text(
            config.minVersion,
            style: AppTextStyle.semiBold(
              52,
              52 * 1.3,
            ).copyWith(color: AppColor.secondarybrandColor, fontWeight: .w500),
          ),
          const Gap(26),
        ],
      ),
    ),
  );
}
