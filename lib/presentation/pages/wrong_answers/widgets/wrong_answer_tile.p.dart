part of '../wrong_answers_page.dart';

class _WrongAnswerTile extends StatelessWidget {
  const _WrongAnswerTile({required this.item, required this.onTap});
  final WrongAnswerEntity item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColor.white,
    child: InkWell(
      key: ValueKey('wrong_answer_${item.questionId}'),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColor.divider)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      ExcludeSemantics(
                        child: Container(
                          width: 27,
                          height: 27,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColor.splashBackground,
                            ),
                          ),
                          child: SvgPicture.asset('assets/icons/note_pdf.svg'),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.surfaceSubtle,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            item.format == QuizFormat.ox
                                ? 'OX퀴즈'
                                : '객관식 ${item.options.length}지선다',
                            style: AppTextStyle.reqular(
                              13,
                              18.85,
                            ).copyWith(color: AppColor.dark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _date(item.lastWrongAt.toLocal()),
                  style: AppTextStyle.reqular(
                    13,
                    18.85,
                  ).copyWith(color: AppColor.secondaryText),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 27),
              child: LayoutBuilder(
                builder: (context, constraints) => Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.materialTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.medium(14, 20.3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: (constraints.maxWidth - 12) / 2,
                      ),
                      child: Text(
                        item.conceptName,
                        maxLines: 2,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.reqular(
                          13,
                          18.85,
                        ).copyWith(color: AppColor.tertiaryText),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.content,
              style: AppTextStyle.reqular(
                15,
                21.75,
              ).copyWith(color: AppColor.danger),
            ),
          ],
        ),
      ),
    ),
  );

  String _date(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${DateFormat('M월 d일').format(date)} (${weekdays[date.weekday - 1]})';
  }
}
