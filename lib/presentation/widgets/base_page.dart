import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// 페이지의 레이아웃과 생명주기 처리를 모은 공통 화면
///
/// 초기화, 앱 상태 변경, 뒤로가기, 화면 구성에는 모두 페이지용
/// [ProviderScope] 내부의 [WidgetRef]를 전달
abstract class BasePage extends HookConsumerWidget {
  const BasePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef outerRef) {
    final argumentOverride = argProviderOverrides;

    return ProviderScope(
      overrides: argumentOverride == null ? [] : [argumentOverride],
      child: HookConsumer(
        builder: (context, pageRef, child) {
          useEffect(() {
            onInit(pageRef);

            var disposed = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (disposed || !context.mounted) return;
              onReady(pageRef);
            });

            return () {
              disposed = true;
              onDispose();
            };
          }, const []);

          useOnAppLifecycleStateChange((previousState, state) {
            switch (state) {
              case AppLifecycleState.resumed:
                onResumed(pageRef);
                break;
              case AppLifecycleState.paused:
                onPaused(pageRef);
                break;
              case AppLifecycleState.inactive:
                onInactive(pageRef);
                break;
              case AppLifecycleState.detached:
                onDetached(pageRef);
                break;
              case AppLifecycleState.hidden:
                onHidden(pageRef);
                break;
            }
          });

          return PopScope(
            canPop: canPop,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              onWillPop(pageRef);
            },
            child: GestureDetector(
              onTap: !preventAutoUnfocus
                  ? () => FocusManager.instance.primaryFocus?.unfocus()
                  : null,
              child: AnnotatedRegion(
                value: SystemUiOverlayStyle(
                  statusBarColor: statusBarColor,
                  statusBarIconBrightness: statusBarIconBrightness,
                  statusBarBrightness: statusBarBrightness,
                  systemNavigationBarColor: systemNavigationBarColor,
                  systemNavigationBarIconBrightness:
                      systemNavigationBarIconBrightness,
                  systemNavigationBarContrastEnforced:
                      systemNavigationBarContrastEnforced,
                ),
                child: Container(
                  color: statusBarColor,
                  child: wrapWithSafeArea
                      ? SafeArea(
                          bottom: setBotomSafeArea,
                          top: setTopSafeArea,
                          child: _buildScaffold(context, pageRef),
                        )
                      : _buildScaffold(context, pageRef),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: extendBody,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: buildAppBar(context, ref),
      body: buildPage(context, ref),
      backgroundColor: pageBackgroundColor,
      bottomNavigationBar: buildBottomNavigationBar(context),
      bottomSheet: buildBottomSheet(context, ref),
    );
  }

  /// 이 페이지의 하위 위젯에 전달할 인자의 override
  ///
  /// 페이지별 override Provider는 dependencies로 사용 범위를 명시
  /// 코드 생성 시 `@Riverpod(dependencies: [])` 지정
  Override? get argProviderOverrides => null;

  @protected
  Widget buildPage(BuildContext context, WidgetRef ref);

  @protected
  Widget? buildBottomNavigationBar(BuildContext context) => null;

  @protected
  Widget? buildBottomSheet(BuildContext context, WidgetRef ref) => null;

  @protected
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) => null;

  @protected
  bool get resizeToAvoidBottomInset => true;

  /// 상단 상태바 배경 색상
  @protected
  Color get statusBarColor => AppColor.white;

  /// Android의 시간·배터리·통신 아이콘 밝기
  @protected
  Brightness get statusBarIconBrightness => Brightness.dark;

  /// IOS 시간·배터리·통신 아이콘 밝기 -> Android와 반대
  @protected
  Brightness get statusBarBrightness => Brightness.light;

  /// Android 하단 시스템 바 배경 색상
  @protected
  Color get systemNavigationBarColor => AppColor.white;

  /// Android 하단 제스처 표시줄이나 내비게이션 버튼을 밝기
  @protected
  Brightness get systemNavigationBarIconBrightness => Brightness.dark;

  /// Android 하단 바 배경 활성화 여부
  @protected
  bool get systemNavigationBarContrastEnforced => true;

  @protected
  Color get pageBackgroundColor => AppColor.white;

  /// 하단 바의 투명한 영역 뒤로 본문을 표시
  @protected
  bool get extendBody => false;

  @protected
  bool get extendBodyBehindAppBar => false;

  @protected
  bool get wrapWithSafeArea => true;

  @protected
  bool get preventAutoUnfocus => false;

  @protected
  bool get setBotomSafeArea => true;

  @protected
  bool get setTopSafeArea => true;

  @protected
  bool get canPop => true;

  /// 뒤로가기 시도가 차단되거나 실패했을 때 호출
  ///
  /// 성공한 뒤로가기에서는 호출하지 않음
  /// 나가기 확인 시 [canPop]을 false로 설정하고 확인 결과에 따라 직접 이동
  @protected
  void onWillPop(WidgetRef ref) {}

  /// 페이지 내부 위젯이 처음 만들어질 때 한 번 호출
  ///
  /// 페이지용 Provider 인자 접근 가능
  /// build 중 실행되므로 구독 중인 Provider 상태 변경·다이얼로그 표시 금지
  /// 초기 데이터 조회는 가능하면 Provider 자체의 초기화에서 처리
  @protected
  void onInit(WidgetRef ref) {}

  /// 첫 프레임의 렌더링이 끝난 뒤 한 번 호출
  ///
  /// 다이얼로그 표시·포커스 요청 등 화면 준비 후 필요한 작업에 사용
  /// 첫 프레임 전에 페이지가 제거되면 호출하지 않음
  /// 비동기 작업 후 ref/context를 다시 사용한다면 mounted를 확인
  @protected
  void onReady(WidgetRef ref) {}

  /// 페이지 내부 위젯이 제거될 때 호출
  ///
  /// 제거된 위젯의 WidgetRef는 사용할 수 없으므로 전달하지 않음
  /// 직접 보관한 자원을 정리하거나, 자원의 소유자가 Hook 또는 Provider라면
  /// 해당 Hook의 자동 정리 또는 Provider의 ref.onDispose를 사용
  @protected
  void onDispose() {}

  /// 앱이 활성 상태로 돌아올 때 호출. 페이지 재진입과는 다름
  @protected
  void onResumed(WidgetRef ref) {}

  /// 앱이 일시 정지될 때 호출
  @protected
  void onPaused(WidgetRef ref) {}

  /// 앱이 비활성 상태로 전환될 때 호출
  @protected
  void onInactive(WidgetRef ref) {}

  /// 앱이 분리되었을 때 호출
  @protected
  void onDetached(WidgetRef ref) {}

  /// 앱의 모든 화면이 숨겨졌을 때 호출
  @protected
  void onHidden(WidgetRef ref) {}
}
