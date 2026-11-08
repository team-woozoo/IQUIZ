part of 'notice_page.dart';

mixin class NoticeState {
  /// 업데이트 안내에 사용할 앱 설정의 데이터·로딩·오류 상태를 구독
  AsyncValue<ConfigEntity> configInfo(WidgetRef ref) {
    return ref.watch(appConfigProvierProvider);
  }
}
