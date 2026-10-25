part of '../material_detail_page.dart';

class _MaterialSummary extends StatelessWidget {
  const _MaterialSummary({required this.material});

  final StudyMaterialEntity material;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: QuizScoreSummary(
        total: material.questionCount,
        correct: material.correctCount,
        // 서버 wrongCount에는 미풀이가 포함되므로 별도로 구분
        wrong: material.answeredCount - material.correctCount,
        unanswered: material.questionCount - material.answeredCount,
        countKeyPrefix: 'material_count',
        horizontalPadding: 0,
        countTextStyle: AppTextStyle.semiBold(28, 39.2),
      ),
    ),
  );
}
