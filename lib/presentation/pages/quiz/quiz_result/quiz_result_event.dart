part of 'quiz_result_page.dart';

mixin class QuizResultEvent {
  void onRestartTapped(BuildContext context, int quizId) {
    if (context.canPop()) {
      context.pop(true);
    } else {
      QuizRoute(quizId).go(context);
    }
  }

  void onBackTapped(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      onUploadTapped(context);
    }
  }

  void onQuizTapped(BuildContext context, int quizId) =>
      QuizRoute(quizId).go(context);

  void onUploadTapped(BuildContext context) => const UploadRoute().go(context);

  void onHomeTapped(BuildContext context) => goToHome(context);
}
