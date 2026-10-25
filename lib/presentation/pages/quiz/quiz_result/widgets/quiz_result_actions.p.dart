part of '../quiz_result_page.dart';

class _QuizResultActions extends StatelessWidget
    with QuizResultEvent, QuizResultState {
  const _QuizResultActions({required this.data});
  final QuizResultRouteArg data;

  @override
  Widget build(BuildContext context) {
    final feedback = insight(data);
    return QuizBottomPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(feedback.title, style: AppTextStyle.semiBold(18, 25.2)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColor.surfaceSubtle,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              feedback.message,
              style: AppTextStyle.reqular(
                14,
                20.3,
              ).copyWith(color: AppColor.secondaryText),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: QuizActionButton(
                  label: '홈',
                  secondary: true,
                  onPressed: () => onHomeTapped(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: QuizActionButton(
                  label: '다시 풀기',
                  onPressed: () => onRestartTapped(context, data.quiz.quizId),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
