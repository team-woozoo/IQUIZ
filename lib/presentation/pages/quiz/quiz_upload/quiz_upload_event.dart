part of 'quiz_upload_page.dart';

mixin class QuizUploadEvent {
  Future<void> onSelectPdf(
    WidgetRef ref,
    QuizUploadFormState form,
    QuizGenerationState generation,
  ) async {
    if (form.selectingFile.value || generation.isBusy) return;
    form.selectingFile.value = true;
    final context = ref.context;
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (!context.mounted || files.isEmpty) return;
      final file = files.first;
      final bytes = await file.readAsBytes();
      if (!context.mounted) return;
      if (bytes.isEmpty) throw const FormatException('빈 PDF입니다.');
      form.selectedPdf.value = (
        bytes: bytes,
        fileName: file.name,
        selectedAt: DateTime.now(),
      );
      form.pages.value = null;
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF 파일을 선택하거나 읽는 중 오류가 발생했습니다.')),
        );
      }
    } finally {
      if (context.mounted) form.selectingFile.value = false;
    }
  }

  void onUpload(
    QuizUploadFormState form,
    QuizGenerationState generation, {
    int? materialId,
    int? conceptId,
  }) {
    final pdf = form.selectedPdf.value;
    if ((pdf == null && materialId == null && conceptId == null) ||
        form.selectingFile.value ||
        generation.isBusy ||
        form.request.value != null) {
      return;
    }
    // 현재 API가 지원하는 유형·난이도만 요청
    // 문항 수와 페이지 선택은 화면의 설정값으로만 유지
    form.request.value = (
      pdf: pdf,
      options: QuizGenerationOptionsEntity(
        format: form.format.value,
        difficulty: form.difficulty.value,
      ),
    );
  }

  void onRetryUpload(QuizUploadFormState form) {
    final request = form.request.value;
    if (request == null) return;
    // 종료된 작업의 상태를 재사용하지 않고 명시적인 새 요청을 생성
    form.request.value = (
      pdf: request.pdf,
      options: QuizGenerationOptionsEntity(
        format: request.options.format,
        difficulty: request.options.difficulty,
      ),
    );
  }

  void onHomeTapped(BuildContext context) => goToHome(context);

  void onQuizTapped(
    BuildContext context,
    int quizId, {
    int? materialId,
    String? materialTitle,
    int? conceptId,
  }) {
    final route = QuizRoute(quizId, title: materialTitle);
    if (materialId != null || conceptId != null) {
      unawaited(route.push<void>(context));
    } else {
      route.go(context);
    }
  }
}
