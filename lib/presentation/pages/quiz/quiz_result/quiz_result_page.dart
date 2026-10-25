import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/presentation/pages/main/main_navigation.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/features/learning_profile/repositories/enums/cognitive_type.enum.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_question_entity.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_result/providers/quiz_result_route_arg.dart';
import 'package:iquiz/presentation/widgets/base_page.dart';
import 'package:iquiz/presentation/pages/quiz/widgets/quiz_toolbar.dart';
import 'package:iquiz/presentation/pages/quiz/widgets/quiz_bottom_panel.dart';
import 'package:iquiz/presentation/pages/quiz/widgets/quiz_action_button.dart';
import 'package:iquiz/presentation/pages/quiz/widgets/quiz_score_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quiz_result_state.dart';
part 'quiz_result_event.dart';
part 'widgets/quiz_result_missing.p.dart';
part 'widgets/quiz_result_summary.p.dart';
part 'widgets/quiz_result_questions.p.dart';
part 'widgets/quiz_result_actions.p.dart';

class QuizResultPage extends BasePage with QuizResultState, QuizResultEvent {
  const QuizResultPage({super.key, required this.quizId, this.result});
  final int quizId;
  final QuizResultRouteArg? result;

  @override
  Override get argProviderOverrides => quizResultRouteArgProvider
      .overrideWithValue(result?.quiz.quizId == quizId ? result : null);

  @override
  PreferredSizeWidget buildAppBar(BuildContext context, WidgetRef ref) =>
      QuizToolbar(onBack: () => onBackTapped(context));

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final data = resultData(ref);
    if (data == null) return _QuizResultMissing(quizId: quizId);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '모든 문제를 풀었어요!',
                              style: AppTextStyle.semiBold(28, 36.4),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.materialTitle ?? '학습 결과',
                              style: AppTextStyle.reqular(
                                15,
                                21.75,
                              ).copyWith(color: AppColor.secondaryText),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 31),
                        child: _QuizResultSummary(data: data),
                      ),
                      _QuizResultQuestions(data: data),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * 0.62,
                ),
                child: _QuizResultActions(data: data),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
