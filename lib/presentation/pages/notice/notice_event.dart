part of 'notice_page.dart';

mixin class NoticeEvent {
  Future<void> onUpdateTapped(WidgetRef ref, Uri uri) async {
    final context = ref.context;
    if (!uri.hasScheme) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('업데이트 주소가 올바르지 않습니다.')));
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) throw StateError('업데이트 주소를 열 수 없습니다.');
    } catch (error, stackTrace) {
      Log.e('업데이트 페이지 열기 실패', error: error, stackTrace: stackTrace);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('업데이트 페이지를 열지 못했습니다.')));
    }
  }
}
