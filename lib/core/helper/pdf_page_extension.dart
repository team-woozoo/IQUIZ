extension PdfPageExtension on Iterable<int> {
  /// 중복·정렬 여부와 관계없이 실제 PDF 페이지를 연속 범위로 표시
  String get pdfPageLabel {
    final sorted = toSet().toList()..sort();
    if (sorted.isEmpty) return '페이지 정보 없음';

    final ranges = <String>[];
    var start = sorted.first;
    var end = start;
    void addRange() => ranges.add(start == end ? '$start' : '$start~$end');

    for (final page in sorted.skip(1)) {
      if (page == end + 1) {
        end = page;
        continue;
      }
      addRange();
      start = end = page;
    }
    addRange();
    return 'PDF ${ranges.join(', ')} 페이지';
  }
}
