import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_option_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_question_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_format.enum.dart';

part 'quiz_option.p.dart';

/// 일반 퀴즈와 오답 한 문제 복습에서 함께 사용하는 문제·보기 UI
class QuizQuestionContent extends StatelessWidget {
  const QuizQuestionContent({
    super.key,
    required this.question,
    required this.format,
    required this.selected,
    required this.checked,
    required this.onSelect,
  });
  final QuizQuestionEntity question;
  final QuizFormat format;
  final int? selected;
  final bool checked;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final options = [
      for (final (index, option) in question.options.indexed)
        _QuizOption(
          number: index + 1,
          option: option,
          selected: selected == option.optionId,
          checked: checked,
          ox: format == QuizFormat.ox,
          onTap: () => onSelect(option.optionId),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (question.conceptName.trim().isNotEmpty) ...[
          Text(
            question.conceptName,
            style: AppTextStyle.reqular(
              15,
              21.75,
            ).copyWith(color: AppColor.secondaryText),
          ),
          const SizedBox(height: 12),
        ],
        Text(question.content, style: AppTextStyle.medium(20, 28)),
        const SizedBox(height: 31),
        if (format == QuizFormat.ox)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < options.length; index++) ...[
                if (index != 0) const SizedBox(width: 12),
                Expanded(child: options[index]),
              ],
            ],
          )
        else
          for (var index = 0; index < options.length; index++) ...[
            if (index != 0) const SizedBox(height: 12),
            options[index],
          ],
      ],
    );
  }
}
