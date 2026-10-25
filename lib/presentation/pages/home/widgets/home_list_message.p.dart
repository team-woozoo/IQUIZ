part of '../home_page.dart';

class _HomeListMessage extends StatelessWidget {
  const _HomeListMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
    child: Column(
      children: [
        Icon(icon, size: 40, color: AppColor.brandColor),
        const SizedBox(height: 16),
        Text(title, textAlign: TextAlign.center, style: AppTextStyle.title4),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyle.reqular(
            14,
            14 * 1.45,
          ).copyWith(color: AppColor.secondaryText),
        ),
        const SizedBox(height: 20),
        OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    ),
  );
}
