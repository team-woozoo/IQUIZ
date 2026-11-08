part of 'quiz_upload_page.dart';

enum _UploadScreen { main, format, difficulty, scope }

typedef SelectedQuizPdf = ({
  Uint8List bytes,
  String fileName,
  DateTime selectedAt,
});

typedef QuizUploadRequest = ({
  SelectedQuizPdf? pdf,
  QuizGenerationOptionsEntity options,
});

typedef QuizUploadFormState = ({
  ValueNotifier<bool> selectingFile,
  ValueNotifier<QuizDifficulty> difficulty,
  ValueNotifier<QuizFormat> format,
  ValueNotifier<int> questionCount,
  ValueNotifier<Set<int>?> pages,
  ValueNotifier<SelectedQuizPdf?> selectedPdf,
  ValueNotifier<QuizUploadRequest?> request,
});

mixin class QuizUploadState {
  /// PDF 선택·문제 유형·난이도·문항 수·페이지 범위·생성 요청의 임시 상태를 생성
  /// build에서 항상 같은 순서로 호출하며 페이지의 Hook 수명주기에 맞춰 유지
  QuizUploadFormState useUploadState() => (
    selectingFile: useState(false),
    difficulty: useState(QuizDifficulty.normal),
    format: useState(QuizFormat.multipleChoice),
    questionCount: useState(10),
    pages: useState<Set<int>?>(null),
    selectedPdf: useState<SelectedQuizPdf?>(null),
    request: useState<QuizUploadRequest?>(null),
  );

  /// [request]에 해당하는 퀴즈 생성 작업을 구독해 화면용 진행 상태를 반환
  /// 요청이 없으면 대기 상태를, 로딩·오류이면 각각 업로드 중·실패 상태를 반환
  QuizGenerationState generationState(
    WidgetRef ref,
    QuizUploadRequest? request, {
    int? materialId,
    String? materialTitle,
    int? conceptId,
    String? conceptName,
  }) {
    final process = request == null
        ? null
        : ref.watch(
            quizUploadProcessProvider(
              fileBytes: request.pdf?.bytes,
              fileName: request.pdf?.fileName,
              materialId: materialId,
              conceptId: conceptId,
              title: conceptName ?? materialTitle,
              options: request.options,
            ),
          );
    return process?.when(
          data: (value) => value,
          loading: () =>
              const QuizGenerationState(status: QuizGenerationStatus.uploading),
          error: (error, _) => QuizGenerationState(
            status: QuizGenerationStatus.failed,
            error: error is Exception ? error : Exception(error.toString()),
          ),
        ) ??
        const QuizGenerationState();
  }

  /// 파일 선택 중이거나 퀴즈 생성이 진행 중인지 반환
  bool isBusy(QuizUploadFormState form, QuizGenerationState generation) =>
      form.selectingFile.value || generation.isBusy;

  /// [value]의 난이도를 화면에 표시할 한글 이름으로 변환
  String difficultyLabel(QuizDifficulty value) => switch (value) {
    QuizDifficulty.easy => '쉬움',
    QuizDifficulty.normal => '보통',
    QuizDifficulty.hard => '어려움',
  };

  /// [value]의 문제 유형을 OX 또는 객관식 안내 문구로 변환
  String formatLabel(QuizFormat value) =>
      value == QuizFormat.ox ? 'OX 퀴즈' : '객관식 4지선다';

  /// [pdf]의 파일명에서 대소문자와 관계없이 끝의 PDF 확장자를 제거해 제목을 반환
  String pdfTitle(SelectedQuizPdf pdf) =>
      pdf.fileName.toLowerCase().endsWith('.pdf')
      ? pdf.fileName.substring(0, pdf.fileName.length - 4)
      : pdf.fileName;

  /// [date]를 월·일·오전오후·시간 형식의 파일 선택 시각으로 표시
  String selectedDate(DateTime date) =>
      DateFormat('M월 d일').format(date) +
      (date.hour < 12 ? ' 오전 ' : ' 오후 ') +
      DateFormat('h:mm').format(date);
}
