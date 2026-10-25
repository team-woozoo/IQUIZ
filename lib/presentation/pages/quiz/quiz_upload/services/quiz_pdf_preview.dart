import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pdfx/pdfx.dart';

final quizPdfPreviewProvider = Provider<QuizPdfPreview>(
  (ref) => const PdfxQuizPdfPreview(),
);

abstract interface class QuizPdfPreview {
  Future<QuizPdfDocument> open(Uint8List bytes);
}

abstract interface class QuizPdfDocument {
  int get pageCount;
  Future<Uint8List> thumbnail(int pageNumber);
  Future<void> close();
}

class PdfxQuizPdfPreview implements QuizPdfPreview {
  const PdfxQuizPdfPreview();

  @override
  Future<QuizPdfDocument> open(Uint8List bytes) async =>
      _PdfxDocument(await PdfDocument.openData(bytes));
}

class _PdfxDocument implements QuizPdfDocument {
  _PdfxDocument(this.document);
  final PdfDocument document;
  Future<void> _queue = Future.value();
  bool _closed = false;

  @override
  int get pageCount => document.pagesCount;

  @override
  Future<Uint8List> thumbnail(int pageNumber) {
    final result = _queue.then((_) async {
      if (_closed) throw StateError('닫힌 PDF입니다.');
      final page = await document.getPage(pageNumber);
      try {
        final image = await page.render(
          width: 240,
          height: 240 * page.height / page.width,
          format: PdfPageImageFormat.png,
          backgroundColor: '#FFFFFF',
        );
        if (image == null) throw const FormatException('페이지를 표시하지 못했어요.');
        return image.bytes;
      } finally {
        await page.close();
      }
    });
    // 네이티브 PDF는 한 번에 한 페이지만 열고, 실패해도 다음 작업은 진행
    _queue = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  @override
  Future<void> close() {
    _closed = true;
    return _queue.then((_) => document.close());
  }
}
