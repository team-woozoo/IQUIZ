/// 학습 분석과 자료 통계가 공통으로 사용하는 풀이 수·정답률 검증
abstract final class LearningStatisticsValidator {
  static void validateAnswers({
    required int answeredCount,
    required int correctCount,
    required double? accuracy,
    String message = '학습 분석 집계가 올바르지 않습니다.',
  }) {
    final validCounts =
        answeredCount >= 0 &&
        correctCount >= 0 &&
        correctCount <= answeredCount;
    final validAccuracy =
        accuracy == null ||
        (accuracy.isFinite && accuracy >= 0 && accuracy <= 1);

    if (!validCounts || !validAccuracy) {
      throw FormatException(message);
    }
  }

  /// 자료 정답률은 전체 문제 수를 기준으로 하며 문제가 없을 때만 null
  static void validateMaterial({
    required int questionCount,
    required int answeredCount,
    required int correctCount,
    required double? accuracy,
  }) {
    const message = '자료 학습 집계가 올바르지 않습니다.';
    validateAnswers(
      answeredCount: answeredCount,
      correctCount: correctCount,
      accuracy: accuracy,
      message: message,
    );

    final validQuestionCount =
        questionCount >= 0 && answeredCount <= questionCount;
    final validAccuracyPresence = questionCount == 0
        ? accuracy == null
        : accuracy != null;
    if (!validQuestionCount || !validAccuracyPresence) {
      throw const FormatException(message);
    }
  }
}
