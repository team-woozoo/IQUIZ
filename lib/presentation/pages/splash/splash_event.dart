part of 'splash_page.dart';

mixin class SplashEvent {
  /// 앱 설정을 읽고 네트워크를 초기화한 뒤 저장된 로그인 상태를 복원
  /// 이전 설정 조회가 실패했으면 다시 요청하고 초기화 예외는 인증 실패 상태로 기록
  Future<void> initData(WidgetRef ref) async {
    final auth = ref.read(userAuthProvider.notifier);
    // 설정을 기다리는 동안에도 인증 상태를 초기화 중으로 표시
    auth.prepareInitialization();

    try {
      if (!await _prepareNetwork(ref)) return;

      // 저장된 인증 정보로 로그인을 복원하고 결과에 따라 인증 상태를 갱신
      await ref.read(userAuthProvider.notifier).initialize();
    } on Exception catch (error) {
      // 초기화 예외는 실패 상태로 기록하고 화면에서 처리
      if (ref.context.mounted) {
        ref.read(userAuthProvider.notifier).initializationFailed(error);
      }
    }
  }

  /// 앱 설정으로 네트워크를 준비하고 실패했던 초기화도 명시적으로 다시 실행
  /// 대기 중 페이지가 제거되면 false를 반환해 후속 인증 작업을 중단
  Future<bool> _prepareNetwork(WidgetRef ref) async {
    if (ref.read(appConfigProvierProvider).hasError) {
      ref.invalidate(appConfigProvierProvider);
    }
    final config = await ref.read(appConfigProvierProvider.future);
    if (!ref.context.mounted) return false;
    final network = initializeNetworkProvider(config.baseUrl);
    ref.invalidate(network);
    ref.read(network);
    return true;
  }

  /// 앱 초기화 후 강제 업데이트 감지를 활성화
  /// 후속 화면 전환은 갱신된 설정·인증 상태에 따라 라우터에서 처리
  Future<void> routePage(WidgetRef ref) async {
    await initData(ref);
    if (!ref.context.mounted) return;
    ref.read(detectForceUpdateProvider);
  }

  /// [controller]의 재생 완료를 스플래시 완료 상태에 반영하는 리스너를 등록
  /// 화면 정리 시 리스너를 해제할 콜백을 반환
  VoidCallback onAnimationAttached(
    WidgetRef ref,
    AnimationController controller,
  ) {
    void onStatusChanged(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        ref.read(splashAnimationProvider.notifier).complete();
      }
    }

    controller.addStatusListener(onStatusChanged);
    return () => controller.removeStatusListener(onStatusChanged);
  }

  /// 스플래시 리소스의 [duration]을 [controller]에 지정하고 재생을 시작
  void onAnimationLoaded(AnimationController controller, Duration duration) {
    controller
      ..duration = duration
      ..forward();
  }

  /// 저장된 인증 정보를 정리해 다시 로그인할 수 있도록 처리
  /// 네트워크가 준비된 경우에만 로그인 화면으로 이동하며 삭제 실패는 메시지로 안내
  Future<void> onSignInAgain(WidgetRef ref) async {
    final context = ref.context;
    try {
      if (!await _prepareNetwork(ref)) return;
      final result = await ref.read(userAuthProvider.notifier).signOut();
      if (!context.mounted) return;
      result.fold(
        onSuccess: (_) {},
        onFailure: (_) => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장된 인증 정보를 삭제하지 못했습니다. 다시 시도해 주세요.')),
        ),
      );
    } on Exception catch (error) {
      if (context.mounted) {
        ref.read(userAuthProvider.notifier).initializationFailed(error);
      }
    }
  }
}
