part of 'quiz_upload_page.dart';

mixin class QuizUploadEvent {
  /// PDF 파일을 선택하고 바이트·파일명·선택 시각을 [form]에 저장
  /// 중복 선택과 생성 중 선택을 막으며 새 PDF를 선택하면 기존 페이지 범위를 초기화
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

  /// 선택한 PDF 또는 [materialId]·[conceptId]로 퀴즈 생성 요청 상태를 설정
  /// 중복 요청을 차단하며 현재 API가 지원하는 문제 유형과 난이도만 전달
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

  /// [form]의 이전 PDF와 생성 옵션으로 새 요청을 구성
  /// 새 옵션 객체를 만들어 종료된 작업의 상태를 재사용하지 않고 명시적으로 재시도
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

  /// 홈 화면으로 이동하고 홈 탭을 선택
  void onHomeTapped(BuildContext context) => goToHome(context);

  /// 생성된 [quizId]의 풀이 화면으로 이동하며 자료 제목을 함께 전달
  /// 기존 자료·약점 개념으로 생성했으면 이전 화면을 유지하고 새 PDF이면 현재 경로를 교체
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
