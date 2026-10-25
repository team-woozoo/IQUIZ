part of 'material_detail_page.dart';

mixin class MaterialDetailState {
  String materialError(Object error) => switch (error) {
    MaterialNotFoundException() => '자료를 찾을 수 없어요.',
    CustomException(:final detail) => detail,
    FormatException(:final message) => message,
    _ => '자료를 불러오지 못했어요. 네트워크 연결을 확인해 주세요.',
  };

  String pageLabel(List<int> pages) {
    final sorted = pages.toSet().toList()..sort();
    if (sorted.isEmpty) return '페이지 정보 없음';
    final ranges = <String>[];
    var start = sorted.first;
    var end = start;
    for (final page in sorted.skip(1)) {
      if (page == end + 1) {
        end = page;
      } else {
        ranges.add(start == end ? '$start' : '$start~$end');
        start = end = page;
      }
    }
    ranges.add(start == end ? '$start' : '$start~$end');
    return 'PDF ${ranges.join(', ')} 페이지';
  }

  String historyDate(DateTime date) {
    final local = date.toLocal();
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${DateFormat('M월 d일').format(local)} (${weekdays[local.weekday - 1]})';
  }
}
