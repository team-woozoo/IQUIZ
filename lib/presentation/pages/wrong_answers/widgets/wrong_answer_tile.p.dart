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
                  child: Text(
                    item.conceptName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.medium(16, 22.4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.materialTitle,
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.medium(16, 22.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _date(item.lastWrongAt.toLocal()),
                    style: AppTextStyle.reqular(
                      13,
                      18.85,
                    ).copyWith(color: AppColor.secondaryText),
                  ),
                ),
                Text(
                  item.sourcePageNo == null
                      ? 'PDF'
                      : 'PDF  ${item.sourcePageNo}페이지',
                  style: AppTextStyle.reqular(
                    13,
                    18.85,
                  ).copyWith(color: AppColor.secondaryText),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(item.content, style: AppTextStyle.reqular(15, 21.75)),
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
