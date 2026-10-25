final class WeakConceptEntity {
  const WeakConceptEntity({
    required this.conceptId,
    required this.conceptName,
    required this.materialId,
    required this.materialTitle,
    required this.answeredCount,
    required this.correctAnswerCount,
    required this.accuracy,
  });

  final int conceptId;
  final String conceptName;

  /// 같은 이름이라도 자료가 다르면 다른 개념
  final int materialId;
  final String materialTitle;

  /// 같은 문제의 반복 풀이는 최근 답안 하나로 집계
  final int answeredCount;
  final int correctAnswerCount;

  /// 0~1 범위의 정답률
  final double accuracy;
}
