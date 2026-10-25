/// 자료 전체 문제 기준의 학습 집계. 오답 수에는 미풀이도 포함
final class StudyMaterialEntity {
  const StudyMaterialEntity({
    required this.materialId,
    required this.title,
    required this.originalFilename,
    required this.pageCount,
    required this.createdAt,
    required this.questionCount,
    required this.answeredCount,
    required this.correctCount,
    required this.wrongCount,
    required this.accuracy,
    required this.generating,
  });

  final int materialId;
  final String title;
  final String originalFilename;

  /// 글자가 있어 저장된 페이지 수이며, 원본 전체 쪽수와 다를 수 있음
  final int pageCount;
  final DateTime createdAt;
  final int questionCount;
  final int answeredCount;
  final int correctCount;
  final int wrongCount;
  final double? accuracy;
  final bool generating;
}
