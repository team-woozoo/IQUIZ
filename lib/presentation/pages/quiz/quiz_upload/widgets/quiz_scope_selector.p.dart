part of '../quiz_upload_page.dart';

class _QuizScopeSelector extends HookConsumerWidget {
  const _QuizScopeSelector({
    required this.pdf,
    required this.count,
    required this.pages,
    required this.onConfirm,
  });
  final SelectedQuizPdf? pdf;
  final int count;
  final Set<int>? pages;
  final void Function(int, Set<int>?) onConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCount = useState(count);
    final selectedPages = useState<Set<int>?>(
      pages == null ? null : Set.of(pages!),
    );
    final attempt = useState(0);
    final future = useMemoized(
      () => pdf == null
          ? null
          : ref.read(quizPdfPreviewProvider).open(pdf!.bytes),
      [pdf, attempt.value],
    );
    final document = useFuture(future);
    useEffect(
      () => () {
        if (future != null) {
          unawaited(
            future
                .then<void>((doc) => doc.close())
                .catchError((Object _, StackTrace _) {}),
          );
        }
      },
      [future],
    );
    final selected = selectedPages.value;
    return _UploadActionLayout(
      action: _UploadBottomAction(
        label: '${selectedCount.value}개 선택 완료',
        onPressed: selected?.isEmpty == true
            ? null
            : () => onConfirm(
                selectedCount.value,
                selected == null ? null : Set.unmodifiable(selected),
              ),
      ),
      child: CustomScrollView(
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.only(top: 10),
            sliver: SliverToBoxAdapter(
              child: _QuizGenerationHeader(title: '출제 범위 및 문항 수'),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 31)),
          _PdfScopePages(
            hasPdf: pdf != null,
            snapshot: document,
            selectedPages: selectedPages,
            onRetry: () => attempt.value++,
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: BaseBottomNavigationBar.overlayHeight),
          ),
        ],
      ),
    );
  }
}

/// 파일 선택, 로딩, 실패, 페이지 표시를 각각 하나의 상태로 렌더링
class _PdfScopePages extends StatelessWidget {
  const _PdfScopePages({
    required this.hasPdf,
    required this.snapshot,
    required this.selectedPages,
    required this.onRetry,
  });

  final bool hasPdf;
  final AsyncSnapshot<QuizPdfDocument> snapshot;
  final ValueNotifier<Set<int>?> selectedPages;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) =>
      switch ((hasPdf, snapshot.hasError, snapshot.data)) {
        (false, _, _) => const _PdfScopeMessage(
          message: 'PDF 파일을 선택하면 출제 범위를 확인할 수 있어요.',
        ),
        (_, true, _) => _PdfScopeMessage(
          message: 'PDF 미리보기를 불러오지 못했어요.',
          onRetry: onRetry,
        ),
        (_, _, final document?) => _pageGrid(document),
        _ => const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      };

  Widget _pageGrid(QuizPdfDocument document) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
    sliver: SliverGrid.builder(
      itemCount: document.pageCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 109 / 146,
      ),
      itemBuilder: (context, index) {
        final page = index + 1;
        final selected = selectedPages.value;
        return _PdfPageChoice(
          key: ValueKey('pdf_page_$page'),
          document: document,
          page: page,
          selected: selected == null || selected.contains(page),
          onTap: () => _togglePage(document.pageCount, page),
        );
      },
    ),
  );

  void _togglePage(int pageCount, int page) {
    final current = selectedPages.value;
    final pages = current == null
        ? {for (var number = 1; number <= pageCount; number++) number}
        : Set<int>.of(current);
    pages.contains(page) ? pages.remove(page) : pages.add(page);
    selectedPages.value = pages;
  }
}

class _PdfScopeMessage extends StatelessWidget {
  const _PdfScopeMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    ),
  );
}

class _PdfPageChoice extends HookWidget {
  const _PdfPageChoice({
    super.key,
    required this.document,
    required this.page,
    required this.selected,
    required this.onTap,
  });
  final QuizPdfDocument document;
  final int page;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final future = useMemoized(() => document.thumbnail(page), [
      document,
      page,
    ]);
    final image = useFuture(future);
    return Semantics(
      label: 'PDF $page페이지',
      selected: selected,
      button: true,
      child: Material(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              switch ((image.data, image.hasError)) {
                (final bytes?, _) => Image.memory(
                  bytes,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
                (_, true) => const Center(
                  child: Icon(
                    Icons.picture_as_pdf_outlined,
                    color: AppColor.disabledText,
                  ),
                ),
                _ => const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              },
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0, 0.55),
                    end: Alignment.bottomCenter,
                    colors: [AppColor.darkTransparent, Color(0x33000000)],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.splashBackground),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              Positioned(
                left: 4,
                top: 4,
                child: SvgPicture.asset(
                  selected
                      ? 'assets/icons/upload_selected.svg'
                      : 'assets/icons/upload_unselected.svg',
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 4,
                child: Text(
                  '$page',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.medium(18, 25.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
