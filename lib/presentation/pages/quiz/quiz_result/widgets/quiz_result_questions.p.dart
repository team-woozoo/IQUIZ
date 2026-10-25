part of '../quiz_result_page.dart';

class _QuizResultQuestions extends StatelessWidget with QuizResultState {
  const _QuizResultQuestions({required this.data});
  final QuizResultRouteArg data;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final concept in conceptResults(data))
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColor.divider)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          concept.name,
                          style: AppTextStyle.medium(16, 22.4),
                        ),
                        Text(
                          '${concept.questionCount}문제',
                          style: AppTextStyle.reqular(
                            13,
                            18.2,
                          ).copyWith(color: AppColor.tertiaryText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pagesLabel(concept.pages),
                      style: AppTextStyle.reqular(
                        14,
                        19.6,
                      ).copyWith(color: AppColor.secondaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: concept.wrong > 0
                      ? AppColor.dangerSubtle
                      : concept.unchecked > 0
                      ? AppColor.neutralSubtle
                      : AppColor.successSubtle,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  concept.wrong > 0
                      ? '${concept.wrong}문제 틀렸어요'
                      : concept.unchecked > 0
                      ? '미풀이'
                      : '완벽해요',
                  style: AppTextStyle.medium(13, 18.2).copyWith(
                    color: concept.wrong > 0
                        ? AppColor.danger
                        : concept.unchecked > 0
                        ? AppColor.secondaryText
                        : AppColor.success,
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}
