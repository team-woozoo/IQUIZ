part of 'notice_page.dart';

mixin class NoticeState {
  AsyncValue<ConfigEntity> configInfo(WidgetRef ref) {
    return ref.watch(appConfigProvierProvider);
  }
}
