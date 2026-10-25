import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_question_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/wrong_answer_entity.dart';
import 'package:iquiz/presentation/pages/quiz/widgets/quiz_action_button.dart';
import 'package:iquiz/presentation/pages/quiz/widgets/quiz_bottom_panel.dart';
import 'package:iquiz/presentation/pages/quiz/widgets/quiz_feedback.dart';
import 'package:iquiz/presentation/pages/quiz/widgets/quiz_question_content.dart';
import 'package:iquiz/presentation/pages/quiz/widgets/quiz_toolbar.dart';
import 'package:iquiz/presentation/pages/wrong_answers/providers/my_wrong_answers_provider.dart';
import 'package:iquiz/presentation/pages/wrong_answers/providers/wrong_answer_review_provider.dart';
import 'package:iquiz/presentation/widgets/base_page.dart';

class WrongAnswerReviewPage extends BasePage {
  const WrongAnswerReviewPage({
    super.key,
    required this.questionId,
    this.question,
  });
  final int questionId;
  final WrongAnswerEntity? question;

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final provided = question;
    if (provided != null && provided.questionId == questionId) {
      return _ReviewSession(key: ValueKey(questionId), item: provided);
    }
    return ref
        .watch(myWrongAnswersProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _unavailable(context, ref, failed: true),
          data: (items) {
            for (final item in items) {
              if (item.questionId == questionId) {
                return _ReviewSession(key: ValueKey(questionId), item: item);
              }
            }
            return _unavailable(context, ref);
          },
        );
  }

  Widget _unavailable(
    BuildContext context,
    WidgetRef ref, {
    bool failed = false,
  }) => Column(
    children: [
      QuizToolbar(onBack: () => _backToNotes(context)),
      Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(failed ? '문제를 불러오지 못했어요.' : '이미 해결했거나 복습할 수 없는 문제예요.'),
              TextButton(
                onPressed: failed
                    ? () => ref.invalidate(myWrongAnswersProvider)
                    : () => _backToNotes(context),
                child: Text(failed ? '다시 시도' : '오답노트로 돌아가기'),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

void _backToNotes(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    const WrongAnswersRoute().go(context);
  }
}

class _ReviewSession extends HookConsumerWidget {
  const _ReviewSession({super.key, required this.item});
  final WrongAnswerEntity item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = useState<int?>(null);
    final provider = wrongAnswerReviewProvider(item.questionId);
    final submission = ref.watch(provider);
    final question = QuizQuestionEntity(
      questionId: item.questionId,
      content: item.content,
      conceptName: item.conceptName,
      cognitiveType: item.cognitiveType,
      explanation: item.explanation,
      sourceQuote: item.sourceQuote,
      sourcePageNo: item.sourcePageNo,
      options: item.options,
    );
    final checked = selected.value != null;
    final correct = question.isCorrectOption(selected.value);

    Future<void> finish() async {
      if (submission.isLoading) return;
      if (submission.hasError) {
        _backToNotes(context);
        return;
      }
      final optionId = selected.value;
      if (optionId == null) return;
      final result = await ref
          .read(provider.notifier)
          .submit(question: item, optionId: optionId);
      if (!context.mounted || result == null) return;
      _backToNotes(context);
    }

    return PopScope(
      canPop: !submission.isLoading,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              QuizToolbar(
                current: 1,
                total: 1,
                onBack: () {
                  if (!submission.isLoading) _backToNotes(context);
                },
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
                          child: QuizQuestionContent(
                            question: question,
                            format: item.format,
                            selected: selected.value,
                            checked: checked,
                            onSelect: (optionId) {
                              if (!checked) selected.value = optionId;
                            },
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
                                if (submission.hasError) ...[
                                  Text(
                                    submission.error is CustomException
                                        ? (submission.error! as CustomException)
                                              .detail
                                        : '저장 결과를 확인하지 못했어요. 목록으로 돌아가 새로고침해 주세요.',
                                    style: AppTextStyle.reqular(
                                      14,
                                      21,
                                    ).copyWith(color: AppColor.danger),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                QuizActionButton(
                                  label: submission.isLoading
                                      ? '결과 저장 중...'
                                      : submission.hasError
                                      ? '오답노트로 돌아가기'
                                      : '복습 완료',
                                  onPressed: submission.isLoading
                                      ? null
                                      : finish,
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
      ),
    );
  }
}
