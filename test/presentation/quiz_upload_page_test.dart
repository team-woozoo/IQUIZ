import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/app/style/app_theme.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/core/services/app_size.dart';
import 'package:iquiz/presentation/widgets/button/base_bottom_navigation_bar.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_job_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_options_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_difficulty.enum.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_format.enum.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_generation_status.enum.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_upload/quiz_upload_page.dart';
import 'package:iquiz/presentation/pages/quiz/quiz_upload/services/quiz_pdf_preview.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';

import '../support/quiz_fakes.dart';
import '../support/home_fakes.dart';

late Uint8List _thumbnailBytes;

void main() {
  late _Picker picker;
  late _UploadRepository repository;
  late _PreviewService previewService;
  late GlobalKey boundary;

  setUpAll(() async {
    final thumbnail = await rootBundle.load('assets/home/review_cover.png');
    _thumbnailBytes = thumbnail.buffer.asUint8List();
    await (FontLoader('pretendard')..addFont(
          rootBundle.load('assets/fonts/pretendard/Pretendard-Regular.otf'),
        ))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  setUp(() {
    final previous = FilePickerPlatform.instance;
    picker = _Picker();
    FilePickerPlatform.instance = picker;
    addTearDown(() => FilePickerPlatform.instance = previous);
    repository = _UploadRepository();
    previewService = _PreviewService();
    addTearDown(() => repository.jobs.close());
  });
  Future<void> start(
    WidgetTester tester, {
    double width = 384,
    double scale = 1,
    bool animate = false,
  }) async {
    tester.view.physicalSize = Size(width, 832);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    boundary = GlobalKey();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quizRepositoryProvider.overrideWithValue(repository),
          userAuthProvider.overrideWith(HomeTestAuth.new),
          quizPdfPreviewProvider.overrideWithValue(previewService),
        ],
        child: RepaintBoundary(
          key: boundary,
          child: MaterialApp(
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              AppSize.init(context);
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                  disableAnimations: !animate,
                ),
                child: child!,
              );
            },
            home: const QuizUploadPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
    // 공통 버튼의 바운스 복귀 후 실행되는 콜백까지 반영
    await tester.pumpAndSettle();
  }

  Future<void> chooseFile(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('upload_file')));
    await tester.pump();
    expect(find.text('PDF 선택 중...'), findsOneWidget);
    picker.selection.complete([_MemoryPdf()]);
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    await tester.pumpAndSettle();
    expect(
      find.text('강의'),
      findsOneWidget,
      reason: tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .join(' / '),
    );
  }

  Future<void> preview(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('UPLOAD_PREVIEWS')) return;
    await tester.runAsync(
      () =>
          precacheImage(MemoryImage(_thumbnailBytes), boundary.currentContext!),
    );
    await tester.pump();
    final render =
        boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await render.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('/private/tmp/iquiz-upload-$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets('기본값과 빈칸 비활성화, 유형·난이도 선택 완료', (tester) async {
    await start(tester);
    expect(find.text('보통 (기본값)'), findsOneWidget);
    expect(find.text('10개 (기본값)'), findsOneWidget);
    expect(
      tester
          .widget<BaseBottomNavigationBar>(find.byType(BaseBottomNavigationBar))
          .onBtnClicked,
      isNull,
    );
    final scroll = find.byType(SingleChildScrollView);
    final bottomBar = find.byType(BaseBottomNavigationBar);
    expect(tester.getBottomLeft(scroll).dy, tester.getBottomLeft(bottomBar).dy);
    expect(tester.getBottomLeft(scroll).dy, 832);
    expect(
      tester
          .widget<SingleChildScrollView>(scroll)
          .padding!
          .resolve(TextDirection.ltr)
          .bottom,
      greaterThanOrEqualTo(tester.getSize(bottomBar).height),
    );
    await preview(tester, 'empty');
    await tap(tester, '문제 유형');
    final blank = find.ancestor(
      of: find.text('빈칸 채우기'),
      matching: find.byType(InkWell),
    );
    expect(tester.widget<InkWell>(blank).onTap, isNull);
    await preview(tester, 'format');
    await tap(tester, 'OX 퀴즈');
    await tap(tester, '선택 완료');
    await tap(tester, '난이도');
    await preview(tester, 'difficulty');
    await tap(tester, '쉬움');
    await tap(tester, '선택 완료');
    expect(find.text('쉬움'), findsOneWidget);
    expect(find.text('OX 퀴즈'), findsOneWidget);
    expect(repository.uploadCount, 0);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('파일 선택은 요청하지 않고 업로드 버튼에서 한 번 생성한다', (tester) async {
    await start(tester);
    await chooseFile(tester);
    expect(repository.uploadCount, 0);
    expect(find.text('강의'), findsOneWidget);
    await preview(tester, 'selected');
    await tap(tester, '문제 유형');
    await tap(tester, 'OX 퀴즈');
    await tap(tester, '선택 완료');
    await tap(tester, '난이도');
    await tap(tester, '쉬움');
    await tap(tester, '선택 완료');
    await tap(tester, '업로드');
    expect(repository.uploadCount, 1);
    expect(repository.options?.difficulty, QuizDifficulty.easy);
    expect(repository.options?.format, QuizFormat.ox);
    expect(repository.bytes, [37, 80, 68, 70]);
    await preview(tester, 'pending');
    repository.jobs.add(
      Result.success(
        const QuizGenerationJobEntity(
          jobId: 9,
          status: QuizGenerationStatus.processing,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('문제 풀기'), findsNothing);
    await preview(tester, 'processing');
    repository.jobs.add(
      Result.success(
        const QuizGenerationJobEntity(
          jobId: 9,
          status: QuizGenerationStatus.done,
          quizId: 7,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('문제 풀기'), findsOneWidget);
    await preview(tester, 'done');
    expect(repository.uploadCount, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('생성 제목의 그라데이션은 반복하다 완료되면 멈추고 위치를 유지한다', (tester) async {
    await start(tester, animate: true);
    await chooseFile(tester);
    tester
        .widget<BaseBottomNavigationBar>(find.byType(BaseBottomNavigationBar))
        .onBtnClicked!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    final title = find.byKey(const ValueKey('quiz_generation_title'));
    final gradient = find.byKey(
      const ValueKey('quiz_generation_title_gradient'),
    );
    expect(gradient, findsOneWidget);
    expect(find.text('생성하고 있어요'), findsOneWidget);
    final bounds = tester.getRect(title);
    expect(tester.binding.hasScheduledFrame, isTrue);
    await preview(tester, 'gradient-start');
    await tester.pump(const Duration(milliseconds: 1000));
    expect(tester.getRect(title), bounds);
    expect(tester.binding.hasScheduledFrame, isTrue);
    await preview(tester, 'gradient-middle');

    repository.jobs.add(
      Result.success(
        const QuizGenerationJobEntity(
          jobId: 9,
          status: QuizGenerationStatus.done,
          quizId: 7,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(gradient, findsOneWidget);
    await tester.pumpAndSettle();
    expect(gradient, findsNothing);
    expect(tester.getRect(title), bounds);
    expect(find.text('문제 풀기'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('문항 수·페이지 선택은 유지하고 서버 요청에는 유형·난이도만 보낸다', (tester) async {
    await start(tester);
    await chooseFile(tester);
    await tap(tester, '문제 수');
    await tester.tap(find.byTooltip('문제 수 늘리기'));
    await tester.pumpAndSettle();
    expect(find.text('11개'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('pdf_page_1')));
    await tester.pumpAndSettle();
    await preview(tester, 'scope');
    await tap(tester, '11개 선택 완료');
    expect(find.text('11개 · 2페이지 선택'), findsOneWidget);
    expect(previewService.documents.single.closed, isTrue);
    expect(repository.uploadCount, 0);
    await tap(tester, '문제 수');
    expect(find.text('11개'), findsOneWidget);
    final semantics = tester.widget<Semantics>(
      find
          .descendant(
            of: find.byKey(const ValueKey('pdf_page_1')),
            matching: find.byType(Semantics),
          )
          .first,
    );
    expect(semantics.properties.selected, isFalse);
    await tap(tester, '11개 선택 완료');
    await tap(tester, '업로드');
    expect(repository.uploadCount, 1);
    expect(repository.options?.format, QuizFormat.multipleChoice);
    expect(repository.options?.difficulty, QuizDifficulty.normal);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('파일 취소와 설정 뒤로가기는 요청 없이 기존 값을 유지한다', (tester) async {
    await start(tester);
    await tester.tap(find.byKey(const ValueKey('upload_file')));
    await tester.pump();
    picker.selection.complete([]);
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    await tester.pumpAndSettle();
    await tap(tester, '난이도');
    await tap(tester, '어려움');
    await tester.tap(find.byTooltip('뒤로가기'));
    await tester.pumpAndSettle();
    expect(find.text('보통 (기본값)'), findsOneWidget);
    expect(repository.uploadCount, 0);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('PDF 미리보기 실패는 재시도로 복구한다', (tester) async {
    previewService.fail = true;
    await start(tester);
    await chooseFile(tester);
    await tap(tester, '문제 수');
    expect(find.text('PDF 미리보기를 불러오지 못했어요.'), findsOneWidget);
    previewService.fail = false;
    await tap(tester, '다시 시도');
    expect(find.byKey(const ValueKey('pdf_page_1')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('생성 실패 상태에서 재시도하고 완료를 임의 표시하지 않는다', (tester) async {
    await start(tester);
    await chooseFile(tester);
    await tap(tester, '업로드');
    repository.jobs.add(
      Result.success(
        const QuizGenerationJobEntity(
          jobId: 9,
          status: QuizGenerationStatus.failed,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('문제 풀기'), findsNothing);
    await tap(tester, '다시 시도');
    for (
      var attempt = 0;
      attempt < 10 && repository.uploadCount < 2;
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(repository.uploadCount, 2);
    expect(find.text('문제 풀기'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('선택 중 화면이 닫히면 늦은 결과를 무시한다', (tester) async {
    await start(tester);
    await tester.tap(find.byKey(const ValueKey('upload_file')));
    await tester.pumpWidget(const SizedBox());
    picker.selection.complete([_MemoryPdf()]);
    await tester.pumpAndSettle();
    expect(repository.uploadCount, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets('작은 화면과 큰 글자에서도 설정을 완료할 수 있다', (tester) async {
    await start(tester, width: 320, scale: 1.5);
    await preview(tester, 'narrow-overlay');
    await tap(tester, '난이도');
    await tap(tester, '어려움');
    await tap(tester, '선택 완료');
    await tap(tester, '문제 수');
    await tap(tester, '10개 선택 완료');
    expect(find.text('문제 생성'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

class _Picker extends FilePickerPlatform {
  late final selection = Completer<List<PlatformFile>>();
  int calls = 0;
  @override
  Future<List<PlatformFile>> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) {
    calls++;
    expect(type, FileType.custom);
    expect(allowedExtensions, ['pdf']);
    return selection.future;
  }
}

final class _MemoryPdf extends PlatformFile {
  @override
  String get name => '강의.pdf';
  @override
  Future<Uint8List> readAsBytes() async => Uint8List.fromList([37, 80, 68, 70]);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UploadRepository extends FakeQuizRepository {
  late final jobs =
      StreamController<Result<QuizGenerationJobEntity>>.broadcast();
  int uploadCount = 0;
  QuizGenerationOptionsEntity? options;
  String? fileName;
  List<int>? bytes;
  @override
  Future<Result<int>> uploadFile({
    required List<int> fileBytes,
    required String fileName,
    required QuizGenerationOptionsEntity options,
    String? title,
  }) async {
    uploadCount++;
    this.options = options;
    this.fileName = fileName;
    bytes = List.of(fileBytes);
    return Result.success(9);
  }

  @override
  Stream<Result<QuizGenerationJobEntity>> watchGenerationJob({
    required int jobId,
  }) => jobs.stream;
}

class _PreviewService implements QuizPdfPreview {
  bool fail = false;
  final documents = <_PreviewDocument>[];
  @override
  Future<QuizPdfDocument> open(Uint8List bytes) async {
    if (fail) throw const FormatException('preview');
    final document = _PreviewDocument();
    documents.add(document);
    return document;
  }
}

class _PreviewDocument implements QuizPdfDocument {
  bool closed = false;
  @override
  int get pageCount => 3;
  @override
  Future<Uint8List> thumbnail(int pageNumber) async {
    return _thumbnailBytes;
  }

  @override
  Future<void> close() async {
    closed = true;
  }
}
