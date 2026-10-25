part of '../quiz_upload_page.dart';

class _QuizGenerationProgress extends StatelessWidget {
  const _QuizGenerationProgress({
    required this.generation,
    required this.onRetry,
    required this.onPlay,
  });
  final QuizGenerationState generation;
  final VoidCallback onRetry;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final done = generation.status == QuizGenerationStatus.done;
    final failed = generation.status == QuizGenerationStatus.failed;
    final accepted =
        generation.status == QuizGenerationStatus.pending ||
        generation.status == QuizGenerationStatus.processing ||
        done;
    const labels = [
      '요청하신 내용을 확인하고 있어요',
      '주제에 맞는 문제를 구상하고 있어요',
      '정답과 해설을 작성하고 있어요',
      '문제 생성을 마무리하고 있어요',
    ];
    return _UploadActionLayout(
      action: done
          ? _UploadBottomAction(label: '문제 풀기', onPressed: onPlay)
          : failed
          ? _UploadBottomAction(label: '다시 시도', onPressed: onRetry)
          : null,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          10,
          16,
          24 + (done || failed ? BaseBottomNavigationBar.overlayHeight : 0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (failed)
              Text('문제 생성을\n완료하지 못했어요', style: AppTextStyle.semiBold(28, 36.4))
            else
              _GenerationTitle(done: done),
            const SizedBox(height: 31),
            for (var index = 0; index < labels.length; index++) ...[
              if (index != 0) const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      labels[index],
                      style: AppTextStyle.medium(
                        16,
                        22.4,
                      ).copyWith(color: AppColor.tertiaryText),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    done || (index == 0 && accepted)
                        ? 'assets/icons/upload_step_done.svg'
                        : 'assets/icons/upload_step_waiting.svg',
                  ),
                ],
              ),
            ],
            if (failed) ...[
              const SizedBox(height: 24),
              Semantics(
                liveRegion: true,
                child: Text(
                  generation.message,
                  style: AppTextStyle.reqular(
                    14,
                    20.3,
                  ).copyWith(color: AppColor.danger),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GenerationTitle extends HookWidget {
  const _GenerationTitle({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 2800),
    );
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final highlight = useAnimationController(
      duration: const Duration(milliseconds: 320),
      initialValue: done || reduceMotion ? 0 : 1,
    );
    useEffect(() {
      if (reduceMotion) {
        controller.stop();
        highlight
          ..stop()
          ..value = 0;
      } else if (done) {
        controller.stop();
        highlight.reverse();
      } else {
        controller.repeat();
        highlight.forward();
      }
      return null;
    }, [done, reduceMotion]);

    final title = Column(
      key: const ValueKey('quiz_generation_title'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('요청하신 문제를', style: AppTextStyle.semiBold(28, 36.4)),
        Text('생성하고 있어요', style: AppTextStyle.semiBold(28, 36.4)),
      ],
    );

    // 글자 폭을 기준으로 빛을 움직여 빈 공간에서만 흐르는 구간을 축소
    return Align(
      alignment: Alignment.centerLeft,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([controller, highlight]),
          child: title,
          builder: (context, child) {
            if (highlight.value == 0) return child!;
            final progress = const Interval(
              0.08,
              0.92,
              curve: Curves.easeInOutSine,
            ).transform(controller.value);
            final offset = progress * 4;
            final intensity = Curves.easeOut.transform(highlight.value);
            Color shade(Color color) =>
                Color.lerp(AppColor.dark, color, intensity)!;
            final base = shade(const Color(0xFF333D4B));
            final shoulder = shade(const Color(0xFF4E5968));
            final light = shade(const Color(0xFF8B95A1));
            return ShaderMask(
              key: const ValueKey('quiz_generation_title_gradient'),
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment(-3 + offset, -0.15),
                end: Alignment(-1 + offset, 0.15),
                colors: [base, shoulder, light, shoulder, base],
                stops: const [0, 0.22, 0.5, 0.78, 1],
              ).createShader(bounds),
              child: child,
            );
          },
        ),
      ),
    );
  }
}
