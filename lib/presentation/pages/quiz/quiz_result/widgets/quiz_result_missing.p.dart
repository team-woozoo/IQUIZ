part of '../quiz_result_page.dart';

class _QuizResultMissing extends StatelessWidget with QuizResultEvent {
  const _QuizResultMissing({required this.quizId});
  final int quizId;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '풀이 결과 정보가 없습니다.\n퀴즈를 풀고 결과를 확인해 주세요.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => onQuizTapped(context, quizId),
            child: const Text('퀴즈 풀기'),
          ),
        ],
      ),
    ),
  );
}
