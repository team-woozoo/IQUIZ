part of 'quiz_play_page.dart';

typedef QuizSessionState = ({
  ValueNotifier<int> index,
  ValueNotifier<Map<int, int>> answers,
  ValueNotifier<Set<int>> checked,
  ValueNotifier<bool> openingResult,
});

mixin class QuizPlayState {
  AsyncValue<QuizEntity> quizAsync(WidgetRef ref) =>
      ref.watch(quizDetailProvider);

  AsyncValue<QuizSubmissionEntity?> submissionAsync(WidgetRef ref) =>
      ref.watch(quizSubmitProvider);

  QuizSessionState useSessionState() => (
    index: useState(0),
    answers: useState<Map<int, int>>({}),
    checked: useState<Set<int>>({}),
    openingResult: useState(false),
  );

  QuizQuestionEntity currentQuestion(
    QuizEntity quiz,
    QuizSessionState session,
  ) => quiz.questions[session.index.value];

  int? selectedOption(QuizEntity quiz, QuizSessionState session) =>
      session.answers.value[currentQuestion(quiz, session).questionId];

  bool isChecked(QuizEntity quiz, QuizSessionState session) =>
      session.checked.value.contains(currentQuestion(quiz, session).questionId);

  bool isLast(QuizEntity quiz, QuizSessionState session) =>
      session.index.value == quiz.questions.length - 1;

  String quizLoadError(Object error) => switch (error) {
    CustomException(:final detail) => detail,
    FormatException(:final message) => message,
    _ => '퀴즈를 불러오지 못했습니다. 네트워크 연결을 확인하고 다시 시도해 주세요.',
  };

  String? submissionError(AsyncValue<QuizSubmissionEntity?> submission) =>
      submission.hasError
      ? switch (submission.error) {
          CustomException(:final detail) => detail,
          FormatException(:final message) => message,
          _ => '답안을 제출하지 못했습니다. 네트워크 연결을 확인하고 다시 시도해 주세요.',
        }
      : null;
}
