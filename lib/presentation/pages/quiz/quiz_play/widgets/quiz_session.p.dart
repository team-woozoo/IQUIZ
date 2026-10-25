part of '../quiz_play_page.dart';

class _QuizSession extends HookConsumerWidget
    with QuizPlayState, QuizPlayEvent {
  const _QuizSession({super.key, required this.quiz, this.title});
  final QuizEntity quiz;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = useSessionState();
    final checked = isChecked(quiz, session);
    final submission = submissionAsync(ref);
    final question = currentQuestion(quiz, session);
    final correct = question.isCorrectOption(selectedOption(quiz, session));
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          children: [
            _QuizQuestionHeader(quiz: quiz, session: session),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        key: ValueKey(session.index.value),
                        padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
                        child: QuizQuestionContent(
                          question: question,
                          format: quiz.format,
                          selected: selectedOption(quiz, session),
                          checked: checked,
                          onSelect: (optionId) => onOptionTapped(
                            session,
                            question.questionId,
                            optionId,
                          ),
                        ),
                      ),
                    ),
                    if (checked)
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight * 0.62,
                        ),
                        child: QuizBottomPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!correct) ...[
                                QuizFeedback(question: question),
                                const SizedBox(height: 24),
                              ],
                              if (submissionError(submission)
                                  case final String message) ...[
                                Text(
                                  message,
                                  style: AppTextStyle.reqular(
                                    14,
                                    21,
                                  ).copyWith(color: AppColor.danger),
                                ),
                                const SizedBox(height: 12),
                              ],
                              _QuizQuestionNavigation(
                                quiz: quiz,
                                session: session,
                                title: title,
                                submitting:
                                    submission.isLoading ||
                                    session.openingResult.value,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
