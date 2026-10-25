part of '../quiz_upload_page.dart';

class _QuizGenerationHeader extends StatelessWidget {
  const _QuizGenerationHeader({
    required this.title,
    this.subtitle = '유형에 맞는 문제를 생성해보세요',
  });
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTextStyle.semiBold(28, 36.4)),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyle.reqular(
            15,
            21.75,
          ).copyWith(color: AppColor.secondaryText),
        ),
      ],
    ),
  );
}
