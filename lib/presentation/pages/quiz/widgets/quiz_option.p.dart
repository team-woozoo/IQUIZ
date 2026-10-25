part of 'quiz_question_content.dart';

class _QuizOption extends StatelessWidget {
  const _QuizOption({
    required this.number,
    required this.option,
    required this.selected,
    required this.checked,
    required this.onTap,
    this.ox = false,
  });
  final int number;
  final QuizOptionEntity option;
  final bool selected;
  final bool checked;
  final VoidCallback onTap;
  final bool ox;

  @override
  Widget build(BuildContext context) {
    final correct = checked && option.isCorrect;
    final wrong = checked && selected && !option.isCorrect;
    final muted = checked && !correct && !wrong;
    final background = correct
        ? AppColor.quizCorrectBackground
        : wrong
        ? AppColor.quizWrongBackground
        : AppColor.surfaceSubtle;
    final accent = correct
        ? AppColor.success
        : wrong
        ? AppColor.danger
        : AppColor.optionNumber;
    final isO = switch (option.content.trim().toUpperCase()) {
      'O' || 'TRUE' || '맞아요' || '예' || '참' => true,
      'X' || 'FALSE' || '아니에요' || '아니오' || '거짓' => false,
      _ => number == 1,
    };
    String oxIcon() {
      if (isO) return correct ? 'quiz_o_correct.svg' : 'quiz_o.svg';
      return wrong
          ? 'quiz_x_wrong.svg'
          : muted
          ? 'quiz_x_disabled.svg'
          : 'quiz_x.svg';
    }

    final oxColor = correct && !isO
        ? AppColor.success
        : wrong && isO
        ? AppColor.danger
        : muted && isO
        ? AppColor.disabledText
        : null;
    final resultLabel = checked
        ? correct
              ? '정답'
              : wrong
              ? '선택한 오답'
              : null
        : null;
    return Semantics(
      selected: selected,
      button: true,
      label: ox
          ? [isO ? 'O, 맞아요' : 'X, 아니에요', ?resultLabel].join(', ')
          : resultLabel,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: ValueKey('quiz_option_${option.optionId}'),
          onTap: checked ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: BoxConstraints(minHeight: ox ? 180 : 56),
            foregroundDecoration: ox || (correct && selected) || wrong
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    // 기본 안쪽 정렬을 전경에 그려 카드 크기와 내용 위치를 유지
                    border: Border.all(
                      color: correct && selected
                          ? AppColor.success
                          : correct
                          ? AppColor.quizCorrectBackground
                          : wrong
                          ? AppColor.danger
                          : background,
                    ),
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            child: ox
                ? Center(
                    child: SvgPicture.asset(
                      'assets/icons/${oxIcon()}',
                      excludeFromSemantics: true,
                      colorFilter: oxColor == null
                          ? null
                          : ColorFilter.mode(oxColor, BlendMode.srcIn),
                    ),
                  )
                : Row(
                    children: [
                      Text(
                        '$number',
                        style: AppTextStyle.semiBold(
                          18,
                          25.2,
                        ).copyWith(color: accent),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StableOptionLabel(
                          content: option.content,
                          emphasized: correct || wrong,
                          color: muted ? AppColor.disabledText : AppColor.dark,
                        ),
                      ),
                      // 결과 아이콘이 생겨도 보기 글의 너비가 줄지 않게 공간을 유지
                      const SizedBox(width: 12),
                      SizedBox.square(
                        dimension: 24,
                        child: correct || wrong
                            ? SvgPicture.asset(
                                correct
                                    ? 'assets/icons/quiz_correct.svg'
                                    : 'assets/icons/quiz_wrong.svg',
                              )
                            : null,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _StableOptionLabel extends StatelessWidget {
  const _StableOptionLabel({
    required this.content,
    required this.emphasized,
    required this.color,
  });
  final String content;
  final bool emphasized;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final defaults = DefaultTextStyle.of(context);
    final regular = defaults.style.merge(AppTextStyle.reqular(18, 25.2));
    final medium = defaults.style.merge(AppTextStyle.medium(18, 25.2));
    return LayoutBuilder(
      builder: (context, constraints) {
        // 두 굵기의 줄바꿈 높이를 모두 확보해 긴 보기·큰 글씨도 잘리지 않음
        var height = 0.0;
        for (final style in [regular, medium]) {
          final painter = TextPainter(
            text: TextSpan(text: content, style: style),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            locale: Localizations.maybeLocaleOf(context),
            textHeightBehavior: defaults.textHeightBehavior,
            textWidthBasis: defaults.textWidthBasis,
          )..layout(maxWidth: constraints.maxWidth);
          if (painter.height > height) height = painter.height;
          painter.dispose();
        }
        return SizedBox(
          height: height,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              content,
              style: (emphasized ? medium : regular).copyWith(color: color),
            ),
          ),
        );
      },
    );
  }
}
