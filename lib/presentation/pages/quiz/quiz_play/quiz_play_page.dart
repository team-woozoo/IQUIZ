import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_question_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_submission_entity.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/providers/quiz_detail_provider.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/providers/quiz_route_arg.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_play/providers/quiz_submit_provider.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_result/providers/quiz_result_route_arg.dart';
import 'package:iquiz/presentation/widgets/base_page.dart';
import 'package:iquiz/presentation/pages/quiz/widgets/quiz_toolbar.dart';
import 'package:iquiz/presentation/pages/quiz/widgets/quiz_bottom_panel.dart';
import 'package:iquiz/presentation/pages/quiz/widgets/quiz_action_button.dart';
import 'package:iquiz/presentation/pages/quiz/widgets/quiz_question_content.dart';
import 'package:iquiz/presentation/pages/quiz/widgets/quiz_feedback.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quiz_play_state.dart';
part 'quiz_play_event.dart';
part 'widgets/quiz_session.p.dart';
part 'widgets/quiz_load_message.p.dart';
part 'widgets/quiz_question_header.p.dart';
part 'widgets/quiz_question_navigation.p.dart';

class QuizPlayPage extends BasePage with QuizPlayState, QuizPlayEvent {
  const QuizPlayPage({super.key, required this.quizId, this.title});
  final int quizId;
  final String? title;

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) => quizAsync(ref).when(
    loading: () =>
        _statusFrame(context, const Center(child: CircularProgressIndicator())),
    error: (error, _) => _statusFrame(
      context,
      _QuizLoadMessage(
        message: quizLoadError(error),
        onRetry: () => onRetry(ref),
      ),
    ),
    data: (quiz) => quiz.questions.isEmpty
        ? _statusFrame(
            context,
            _QuizLoadMessage(
              message: '아직 풀 수 있는 문제가 없습니다.',
              onRetry: () => onRetry(ref),
            ),
          )
        : _QuizSession(key: ValueKey(quiz.quizId), quiz: quiz, title: title),
  );

  Widget _statusFrame(BuildContext context, Widget child) => Column(
    children: [
      QuizToolbar(onBack: () => onBackTapped(context)),
      Expanded(child: child),
    ],
  );

  @override
  Override get argProviderOverrides =>
      quizRouteArgProvider.overrideWithValue(quizId);
}
