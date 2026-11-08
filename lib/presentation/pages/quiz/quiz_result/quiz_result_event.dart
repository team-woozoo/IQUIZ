part of 'quiz_result_page.dart';

mixin class QuizResultEvent {
  /// 이전 풀이 화면에 다시 풀기 결과를 반환하며 닫기
  /// 돌아갈 화면이 없으면 [quizId]의 풀이 화면으로 이동
  void onRestartTapped(BuildContext context, int quizId) {
    if (context.canPop()) {
      context.pop(true);
    } else {
      QuizRoute(quizId).go(context);
    }
  }

  /// 이전 화면으로 돌아가며 돌아갈 화면이 없으면 업로드 화면으로 이동
  void onBackTapped(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      onUploadTapped(context);
    }
  }

  /// [quizId]에 해당하는 퀴즈 풀이 화면으로 이동
  void onQuizTapped(BuildContext context, int quizId) =>
      QuizRoute(quizId).go(context);

  /// 학습 자료 업로드 화면으로 이동
  void onUploadTapped(BuildContext context) => const UploadRoute().go(context);

  /// 홈 화면으로 이동하고 홈 탭을 선택
  void onHomeTapped(BuildContext context) => goToHome(context);
}
