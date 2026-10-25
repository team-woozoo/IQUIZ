part of '../profile_page.dart';

const _cognitiveLabels = {
  CognitiveType.remember: '외우기',
  CognitiveType.understand: '이해하기',
  CognitiveType.apply: '응용하기',
  CognitiveType.analyze: '비교하기',
  CognitiveType.evaluate: '판단하기',
};

class _ProfileScoreChart extends StatelessWidget {
  const _ProfileScoreChart({required this.scores});
  final List<CognitiveTypeScoreEntity> scores;

  @override
  Widget build(BuildContext context) {
    final byType = {for (final score in scores) score.cognitiveType: score};
    final enough =
        scores.where((s) => s.isEnoughData && s.accuracy != null).toList()
          ..sort((a, b) => a.accuracy!.compareTo(b.accuracy!));
    // 모든 유형의 정답률이 같을 때는 특정 유형을 약점으로 강조하지 않음
    final weakest =
        enough.length > 1 && enough.first.accuracy != enough.last.accuracy
        ? enough.first.cognitiveType
        : null;
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 18;
    Widget label(CognitiveType type) => _ProfileScoreLabel(
      type: type,
      score: byType[type],
      highlighted: weakest == type,
    );
    final chart = SizedBox(
      width: 352,
      height: largeText ? 176 : 272,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: largeText ? -48 : 0,
            width: 352,
            height: 272,
            child: ExcludeSemantics(
              child: Stack(
                children: [
                  // Figma의 정적 눈금과 축은 원본 SVG 크기로 배치
                  for (final (asset, x, y) in const [
                    ('grid_outer', 96.212, 63.44),
                    ('grid_middle', 123.1925, 90.54),
                    ('grid_inner', 149.3396, 116.81),
                    ('axis_remember', 175.5683, 64.0),
                    ('axis_understand', 175.873, 118.59),
                    ('axis_apply', 175.66, 143.28),
                    ('axis_analyze', 126.6923, 143.28),
                    ('axis_evaluate', 96.5971, 118.59),
                  ])
                    Positioned(
                      left: x,
                      top: y,
                      child: SvgPicture.asset(
                        'assets/icons/profile_$asset.svg',
                      ),
                    ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ProfileScorePainter(byType, weakest),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!largeText) ...[
            for (final (type, x, y) in const [
              (CognitiveType.remember, 134.0, 0.0),
              (CognitiveType.understand, 252.0, 92.0),
              (CognitiveType.apply, 185.0, 220.0),
              (CognitiveType.analyze, 85.0, 220.0),
              (CognitiveType.evaluate, 18.0, 92.0),
            ])
              Positioned(left: x, top: y, width: 84, child: label(type)),
          ],
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: FittedBox(fit: BoxFit.scaleDown, child: chart),
        ),
        if (largeText)
          for (final type in CognitiveType.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: label(type),
            ),
        if (scores.every((s) => s.answeredCount == 0)) ...[
          const SizedBox(height: 16),
          Text(
            '퀴즈를 풀면 나의 학습 분석이 나타나요',
            textAlign: TextAlign.center,
            style: AppTextStyle.reqular(
              14,
              20.3,
            ).copyWith(color: AppColor.secondaryText),
          ),
        ],
      ],
    );
  }
}

class _ProfileScoreLabel extends StatelessWidget {
  const _ProfileScoreLabel({
    required this.type,
    required this.score,
    required this.highlighted,
  });
  final CognitiveType type;
  final CognitiveTypeScoreEntity? score;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final current = score;
    final unplayed =
        current == null ||
        current.answeredCount == 0 ||
        current.accuracy == null;
    final enough = !unplayed && current.isEnoughData;
    final value = unplayed
        ? '미풀이'
        : !enough
        ? '데이터 부족'
        : '${(current.accuracy! * 100).round()}%';
    return Semantics(
      label:
          '${_cognitiveLabels[type]}, $value${current == null ? '' : ', ${current.answeredCount}문제 풀이'}',
      excludeSemantics: true,
      child: Column(
        key: ValueKey('profile_score_${type.name}'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _cognitiveLabels[type]!,
            style: AppTextStyle.medium(
              14,
              20.3,
            ).copyWith(color: AppColor.secondaryText),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style:
                (enough
                        ? AppTextStyle.medium(24, 33.6)
                        : AppTextStyle.medium(13, 33.6))
                    .copyWith(
                      color: highlighted
                          ? AppColor.danger
                          : enough
                          ? AppColor.dark
                          : AppColor.secondaryText,
                    ),
          ),
        ],
      ),
    );
  }
}

class _ProfileScorePainter extends CustomPainter {
  const _ProfileScorePainter(this.scores, this.weakest);
  final Map<CognitiveType, CognitiveTypeScoreEntity> scores;
  final CognitiveType? weakest;

  @override
  void paint(Canvas canvas, Size size) {
    const center = Offset(176, 143.616);
    const vertices = [
      Offset(176, 64),
      Offset(255.27, 119.03),
      Offset(225, 208),
      Offset(127, 208),
      Offset(96.73, 119.03),
    ];
    final points = <Offset?>[
      for (final (i, type) in CognitiveType.values.indexed)
        if (scores[type] case final score?
            when score.isEnoughData && score.accuracy != null)
          Offset.lerp(center, vertices[i], score.accuracy!)
        else
          null,
    ];
    final stroke = Paint()
      ..color = AppColor.brandColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7;
    if (points.every((p) => p != null)) {
      final path = Path()..addPolygon(points.cast<Offset>(), true);
      canvas.drawPath(
        path,
        Paint()..color = AppColor.brandColor.withValues(alpha: 0.18),
      );
      canvas.drawPath(path, stroke);
    } else {
      // 부족한 데이터를 0%로 연결하지 않고, 확인된 값만 그리기
      for (var i = 0; i < points.length; i++) {
        final a = points[i];
        final b = points[(i + 1) % points.length];
        if (a != null && b != null) canvas.drawLine(a, b, stroke);
      }
    }
    for (final (i, point) in points.indexed) {
      if (point == null) continue;
      canvas.drawCircle(point, 4.8, Paint()..color = AppColor.white);
      canvas.drawCircle(
        point,
        3.8,
        Paint()
          ..color = CognitiveType.values[i] == weakest
              ? AppColor.danger
              : AppColor.brandColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProfileScorePainter oldDelegate) =>
      oldDelegate.scores != scores || oldDelegate.weakest != weakest;
}
