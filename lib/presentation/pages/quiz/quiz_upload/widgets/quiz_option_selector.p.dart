part of '../quiz_upload_page.dart';

class _QuizFormatSelector extends HookWidget {
  const _QuizFormatSelector({required this.initial, required this.onConfirm});
  final QuizFormat initial;
  final ValueChanged<QuizFormat> onConfirm;

  @override
  Widget build(BuildContext context) {
    final selected = useState(initial);
    return _UploadSelectionLayout(
      title: '문제 유형 선택',
      onConfirm: () => onConfirm(selected.value),
      children: [
        _UploadChoice(
          title: '객관식 4지선다',
          description: '표준 개념 검증 및 계산형 문항을 생성해요',
          defaultValue: true,
          selected: selected.value == QuizFormat.multipleChoice,
          onTap: () => selected.value = QuizFormat.multipleChoice,
        ),
        _UploadChoice(
          title: 'OX 퀴즈',
          description: '핵심 명제 및 오개념 판별 훈련을 해요',
          selected: selected.value == QuizFormat.ox,
          onTap: () => selected.value = QuizFormat.ox,
        ),
        const _UploadChoice(
          title: '빈칸 채우기',
          description: '핵심 프로토콜 키워드 능동 회상을 해요',
          selected: false,
          onTap: null,
        ),
      ],
    );
  }
}

class _QuizDifficultySelector extends HookWidget {
  const _QuizDifficultySelector({
    required this.initial,
    required this.onConfirm,
  });
  final QuizDifficulty initial;
  final ValueChanged<QuizDifficulty> onConfirm;

  @override
  Widget build(BuildContext context) {
    final selected = useState(initial);
    return _UploadSelectionLayout(
      title: '문제 난이도 선택',
      onConfirm: () => onConfirm(selected.value),
      children: [
        _UploadChoice(
          title: '쉬움',
          description: '표준 개념 검증 및 계산형 문항을 생성해요',
          selected: selected.value == QuizDifficulty.easy,
          onTap: () => selected.value = QuizDifficulty.easy,
        ),
        _UploadChoice(
          title: '보통',
          description: 'Bloom 인지 수준 및 실제 중간, 기말 대학 시험 변형 문제 위주로 출제돼요',
          defaultValue: true,
          selected: selected.value == QuizDifficulty.normal,
          onTap: () => selected.value = QuizDifficulty.normal,
        ),
        _UploadChoice(
          title: '어려움',
          description: '핵심 프로토콜 키워드 능동 회상을 해요',
          selected: selected.value == QuizDifficulty.hard,
          onTap: () => selected.value = QuizDifficulty.hard,
        ),
      ],
    );
  }
}

class _UploadSelectionLayout extends StatelessWidget {
  const _UploadSelectionLayout({
    required this.title,
    required this.children,
    required this.onConfirm,
  });
  final String title;
  final List<Widget> children;
  final VoidCallback onConfirm;
  @override
  Widget build(BuildContext context) => _UploadActionLayout(
    action: _UploadBottomAction(label: '선택 완료', onPressed: onConfirm),
    child: SingleChildScrollView(
      padding: EdgeInsets.only(
        top: 10,
        bottom: BaseBottomNavigationBar.overlayHeight + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _QuizGenerationHeader(title: title),
          const SizedBox(height: 31),
          ...children,
        ],
      ),
    ),
  );
}

class _UploadChoice extends StatelessWidget {
  const _UploadChoice({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
    this.defaultValue = false,
  });
  final String title;
  final String description;
  final bool selected;
  final VoidCallback? onTap;
  final bool defaultValue;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    enabled: onTap != null,
    button: true,
    child: Material(
      color: AppColor.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          style: AppTextStyle.medium(18, 25.2).copyWith(
                            color: onTap == null
                                ? AppColor.disabledText
                                : AppColor.dark,
                          ),
                        ),
                        if (defaultValue)
                          Text(
                            '기본값',
                            style: AppTextStyle.reqular(
                              14,
                              19.6,
                            ).copyWith(color: AppColor.disabledText),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: AppTextStyle.reqular(14, 20.3).copyWith(
                        color: onTap == null
                            ? AppColor.disabledText
                            : AppColor.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SvgPicture.asset(
                selected
                    ? 'assets/icons/upload_selected.svg'
                    : 'assets/icons/upload_unselected.svg',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
