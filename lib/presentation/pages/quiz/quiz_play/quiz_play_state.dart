part of 'quiz_play_page.dart';

typedef QuizSessionState = ({
  ValueNotifier<int> index,
  ValueNotifier<Map<int, int>> answers,
  ValueNotifier<Set<int>> checked,
  ValueNotifier<bool> openingResult,
});

mixin class QuizPlayState {
  /// 현재 화면에 주입된 퀴즈의 데이터·로딩·오류 상태를 구독
  AsyncValue<QuizEntity> quizAsync(WidgetRef ref) =>
      ref.watch(quizDetailProvider);

  /// 현재 퀴즈의 답안 제출 상태와 채점 결과를 구독
  AsyncValue<QuizSubmissionEntity?> submissionAsync(WidgetRef ref) =>
      ref.watch(quizSubmitProvider);

  /// 풀이 중인 문제 위치·선택 답안·확인한 문제·결과 화면 이동 상태를 생성
  /// build에서 항상 같은 순서로 호출하며 페이지의 Hook 수명주기에 맞춰 유지
  QuizSessionState useSessionState() => (
    index: useState(0),
    answers: useState<Map<int, int>>({}),
    checked: useState<Set<int>>({}),
    openingResult: useState(false),
  );

  /// [quiz]에서 [session]의 현재 위치에 해당하는 문제를 반환
  QuizQuestionEntity currentQuestion(
    QuizEntity quiz,
    QuizSessionState session,
  ) => quiz.questions[session.index.value];

  /// 현재 문제에서 선택한 보기 ID를 반환하며 아직 선택하지 않았으면 null을 반환
  int? selectedOption(QuizEntity quiz, QuizSessionState session) =>
      session.answers.value[currentQuestion(quiz, session).questionId];

  /// 현재 문제가 [session]의 정답 확인 완료 목록에 포함되는지 반환
  bool isChecked(QuizEntity quiz, QuizSessionState session) =>
      session.checked.value.contains(currentQuestion(quiz, session).questionId);

  /// [session]의 현재 위치가 [quiz]의 마지막 문제인지 반환
  bool isLast(QuizEntity quiz, QuizSessionState session) =>
      session.index.value == quiz.questions.length - 1;

  /// [error]의 상세 메시지 또는 퀴즈 조회 실패에 대한 기본 안내 문구를 반환
  String quizLoadError(Object error) => switch (error) {
    CustomException(:final detail) => detail,
    FormatException(:final message) => message,
    _ => '퀴즈를 불러오지 못했습니다. 네트워크 연결을 확인하고 다시 시도해 주세요.',
  };

  /// [submission]이 실패 상태이면 상세 오류 또는 기본 제출 실패 문구를 반환
  /// 오류가 없으면 null을 반환
  String? submissionError(AsyncValue<QuizSubmissionEntity?> submission) =>
      submission.hasError
      ? switch (submission.error) {
          CustomException(:final detail) => detail,
          FormatException(:final message) => message,
          _ => '답안을 제출하지 못했습니다. 네트워크 연결을 확인하고 다시 시도해 주세요.',
        }
      : null;
}
