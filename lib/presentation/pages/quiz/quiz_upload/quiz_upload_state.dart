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
  QuizUploadFormState useUploadState() => (
    selectingFile: useState(false),
    difficulty: useState(QuizDifficulty.normal),
    format: useState(QuizFormat.multipleChoice),
    questionCount: useState(10),
    pages: useState<Set<int>?>(null),
    selectedPdf: useState<SelectedQuizPdf?>(null),
    request: useState<QuizUploadRequest?>(null),
  );

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

  bool isBusy(QuizUploadFormState form, QuizGenerationState generation) =>
      form.selectingFile.value || generation.isBusy;

  String difficultyLabel(QuizDifficulty value) => switch (value) {
    QuizDifficulty.easy => '쉬움',
    QuizDifficulty.normal => '보통',
    QuizDifficulty.hard => '어려움',
  };

  String formatLabel(QuizFormat value) =>
      value == QuizFormat.ox ? 'OX 퀴즈' : '객관식 4지선다';

  String pdfTitle(SelectedQuizPdf pdf) =>
      pdf.fileName.toLowerCase().endsWith('.pdf')
      ? pdf.fileName.substring(0, pdf.fileName.length - 4)
      : pdf.fileName;

  String selectedDate(DateTime date) =>
      DateFormat('M월 d일').format(date) +
      (date.hour < 12 ? ' 오전 ' : ' 오후 ') +
      DateFormat('h:mm').format(date);
}
