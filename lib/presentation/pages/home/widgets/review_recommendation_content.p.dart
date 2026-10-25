part of '../home_page.dart';

class _ReviewRecommendationContent extends StatelessWidget {
  const _ReviewRecommendationContent({
    this.materialTitle,
    this.title,
    this.message,
    this.onTap,
    this.loading = false,
  });

  final String? materialTitle;
  final String? title;
  final String? message;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) => Material(
    key: const ValueKey('home_review_recommendation'),
    color: AppColor.surfaceSubtle,
    borderRadius: BorderRadius.circular(12),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            if (loading || materialTitle != null) ...[
              const _ReviewBookCover(),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: loading
                  ? Semantics(
                      label: '복습할 개념을 불러오는 중이에요',
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ReviewSkeletonLine(height: 22.4),
                          SizedBox(height: 4),
                          FractionallySizedBox(
                            widthFactor: 0.8,
                            child: _ReviewSkeletonLine(height: 20.3),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title!,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.semiBold(16, 22.4),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message!,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.reqular(
                            14,
                            20.3,
                          ).copyWith(color: AppColor.secondaryText),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ReviewSkeletonLine extends StatelessWidget {
  const _ReviewSkeletonLine({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      color: AppColor.skeletonColor.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}
