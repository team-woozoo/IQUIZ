import 'package:flutter/material.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/core/constants/app_color.dart';

class QuizScoreSummary extends StatelessWidget {
  const QuizScoreSummary({
    super.key,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.unanswered,
    required this.countKeyPrefix,
    this.horizontalPadding = 16,
    this.countTextStyle,
  });

  final int total;
  final int correct;
  final int wrong;
  final int unanswered;
  final String countKeyPrefix;
  final double horizontalPadding;
  final TextStyle? countTextStyle;

  @override
  Widget build(BuildContext context) {
    final counts = [total, correct, wrong, unanswered];
    const labels = ['문제', '정답', '오답', '미풀이'];
    const colors = [
      AppColor.dark,
      AppColor.success,
      AppColor.danger,
      AppColor.secondaryText,
    ];
    return ColoredBox(
      color: AppColor.surfaceSubtle,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          children: [
            for (var index = 0; index < counts.length; index++) ...[
              if (index != 0)
                Container(
                  width: 1,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${counts[index]}',
                        key: ValueKey('${countKeyPrefix}_$index'),
                        style: (countTextStyle ?? AppTextStyle.medium(28, 39.2))
                            .copyWith(color: colors[index]),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        labels[index],
                        style: AppTextStyle.reqular(
                          14,
                          19.6,
                        ).copyWith(color: AppColor.tertiaryText),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
