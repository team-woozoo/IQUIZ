part of '../quiz_upload_page.dart';

class _QuizGenerationOptions extends StatelessWidget with QuizUploadState {
  const _QuizGenerationOptions({
    required this.form,
    required this.busy,
    required this.onSelectPdf,
    required this.onOpen,
    required this.onUpload,
    this.materialId,
    this.materialTitle,
    this.conceptId,
    this.conceptName,
  });
  final QuizUploadFormState form;
  final int? materialId;
  final String? materialTitle;
  final int? conceptId;
  final String? conceptName;
  final bool busy;
  final VoidCallback onSelectPdf;
  final ValueChanged<_UploadScreen> onOpen;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final pdf = form.selectedPdf.value;
    final difficulty = difficultyLabel(form.difficulty.value);
    final format = formatLabel(form.format.value);
    final count = form.questionCount.value;
    final pages = form.pages.value;
    return _UploadActionLayout(
      action: _UploadBottomAction(
        label: conceptId != null
            ? '약점 문제 5개 생성'
            : materialId == null
            ? '업로드'
            : '문제 생성',
        onPressed:
            (pdf == null && materialId == null && conceptId == null) || busy
            ? null
            : onUpload,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: 10,
          bottom: BaseBottomNavigationBar.overlayHeight + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _QuizGenerationHeader(
              title: conceptId != null ? '약점 문제 생성' : '문제 생성',
              subtitle: conceptId != null
                  ? '선택한 개념으로 문제 5개를 만들어요'
                  : '맞춤 문제를 생성해보세요',
            ),
            const SizedBox(height: 31),
            _SettingsSectionTitle(
              conceptId != null
                  ? '복습할 개념'
                  : materialId == null
                  ? '파일 업로드'
                  : '학습 자료',
            ),
            const SizedBox(height: 12),
            _UploadSettingRow(
              key: const ValueKey('upload_file'),
              title: conceptId != null
                  ? (conceptName ?? '약한 개념')
                  : materialId != null
                  ? (materialTitle ?? '학습 자료')
                  : form.selectingFile.value
                  ? 'PDF 선택 중...'
                  : pdf == null
                  ? '파일을 업로드해주세요'
                  : pdfTitle(pdf),
              subtitle: conceptId != null
                  ? '이 개념이 나온 페이지로 문제를 생성해요'
                  : materialId != null
                  ? '현재 자료로 문제를 생성해요'
                  : pdf == null
                  ? '파일을 업로드해주세요'
                  : selectedDate(pdf.selectedAt),
              pdf: conceptId == null,
              showChevron: materialId == null && conceptId == null,
              onTap: busy || materialId != null || conceptId != null
                  ? null
                  : onSelectPdf,
            ),
            const SizedBox(height: 31),
            const _SettingsSectionTitle('문제 설정'),
            const SizedBox(height: 12),
            _UploadSettingRow(
              key: const ValueKey('upload_format'),
              title: '문제 유형',
              subtitle:
                  format +
                  (form.format.value == QuizFormat.multipleChoice
                      ? ' (기본값)'
                      : ''),
              onTap: busy ? null : () => onOpen(_UploadScreen.format),
            ),
            _UploadSettingRow(
              key: const ValueKey('upload_difficulty'),
              title: '난이도',
              subtitle:
                  difficulty +
                  (form.difficulty.value == QuizDifficulty.normal
                      ? ' (기본값)'
                      : ''),
              onTap: busy ? null : () => onOpen(_UploadScreen.difficulty),
            ),
            if (materialId == null && conceptId == null)
              _UploadSettingRow(
                key: const ValueKey('upload_count'),
                title: '문제 수',
                subtitle:
                    '$count개${count == 10 ? ' (기본값)' : ''}${pages == null ? '' : ' · ${pages.length}페이지 선택'}',
                onTap: busy ? null : () => onOpen(_UploadScreen.scope),
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  const _SettingsSectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(title, style: AppTextStyle.semiBold(18, 25.2)),
  );
}

class _UploadSettingRow extends StatelessWidget {
  const _UploadSettingRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.pdf = false,
    this.showChevron = true,
  });
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool pdf;
  final bool showChevron;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColor.white,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (pdf) ...[
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColor.splashBackground),
                ),
                child: SvgPicture.asset('assets/icons/upload_pdf.svg'),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.medium(16, 22.4),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyle.reqular(
                      14,
                      19.6,
                    ).copyWith(color: AppColor.secondaryText),
                  ),
                ],
              ),
            ),
            if (showChevron) ...[
              const SizedBox(width: 10),
              SvgPicture.asset('assets/icons/upload_chevron.svg'),
            ],
          ],
        ),
      ),
    ),
  );
}
