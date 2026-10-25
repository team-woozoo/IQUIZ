import 'package:flutter/material.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_question_entity.dart';

class QuizFeedback extends StatelessWidget {
  const QuizFeedback({super.key, required this.question});
  final QuizQuestionEntity question;

  @override
  Widget build(BuildContext context) {
    final quote = question.sourceQuote.trim();
    final explanation = question.explanation.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('문제 해설', style: AppTextStyle.semiBold(18, 25.2)),
            ),
            if (question.sourcePageNo case final int page) ...[
              const SizedBox(width: 8),
              Container(
                key: const ValueKey('quiz_feedback_source_badge'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColor.splashBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icons/quiz_source_pdf.png',
                      key: const ValueKey('quiz_feedback_source_icon'),
                      width: 14,
                      height: 14,
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(width: 4),
                    Text('$page페이지', style: AppTextStyle.medium(12, 17.4)),
                  ],
                ),
              ),
            ],
          ],
        ),
        if (quote.isNotEmpty || explanation.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            key: const ValueKey('quiz_feedback_explanation'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColor.surfaceSubtle,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              quote.isNotEmpty ? quote : explanation,
              style: AppTextStyle.reqular(
                14,
                20.3,
              ).copyWith(color: AppColor.secondaryText),
            ),
          ),
        ],
      ],
    );
  }
}
