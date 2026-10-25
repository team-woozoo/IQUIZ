part of '../notice_page.dart';

class _NoticeDetails extends StatelessWidget {
  const _NoticeDetails({required this.config});
  final ConfigEntity config;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: EdgeInsets.fromLTRB(16, 0, 16, 52 + AppSize.bottomInset + 24),
    sliver: SliverList.builder(
      itemCount: config.details.length,
      itemBuilder: (context, index) {
        final content = config.details[index];
        return Padding(
          padding: EdgeInsets.only(top: index > 0 ? 24 : 0),
          child: Column(
            key: ValueKey('notice-$index'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.title,
                style: AppTextStyle.title3.copyWith(
                  color: AppColor.dark,
                  fontWeight: .w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                content.description,
                style: AppTextStyle.body1.copyWith(
                  color: AppColor.secondaryText,
                  fontWeight: .w400,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
