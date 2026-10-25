part of 'splash_page.dart';

mixin class SplashEvent {
  /// 앱 설정이 준비된 뒤 기존 로그인 상태를 복원
  Future<void> initData(WidgetRef ref) async {
    final auth = ref.read(userAuthProvider.notifier);
    // 설정을 기다리는 동안에도 인증 상태를 초기화 중으로 표시
    auth.prepareInitialization();

    try {
      // 이전 설정 로딩이 실패했다면 기존 상태를 무효화해 다시 불러오기
      if (ref.read(appConfigProvierProvider).hasError) {
        ref.invalidate(appConfigProvierProvider);
      }

      // 설정 데이터가 준비될 때까지 대기. 이미 로딩됐다면 현재 값을 사용
      final config = await ref.read(appConfigProvierProvider.future);

      // 대기 중 화면이 제거됐다면 이후 초기화를 진행하지 않음
      if (!ref.context.mounted) return;

      ref.read(initializeNetworkProvider(config.baseUrl));

      // 저장된 인증 정보로 로그인을 복원하고 결과에 따라 인증 상태를 갱신
      await ref.read(userAuthProvider.notifier).initialize();
    } on Exception catch (error) {
      // 초기화 예외는 실패 상태로 기록하고 화면에서 처리
      if (ref.context.mounted) {
        ref.read(userAuthProvider.notifier).initializationFailed(error);
      }
    }
  }

  Future<void> routePage(WidgetRef ref) async {
    await initData(ref);
    if (!ref.context.mounted) return;
    ref.read(detectForceUpdateProvider);
  }

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

  void onAnimationLoaded(AnimationController controller, Duration duration) {
    controller
      ..duration = duration
      ..forward();
  }

  Future<void> onSignInAgain(WidgetRef ref) async {
    final context = ref.context;
    final result = await ref.read(userAuthProvider.notifier).signOut();
    if (!context.mounted) return;
    result.fold(
      onSuccess: (_) {},
      onFailure: (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장된 인증 정보를 삭제하지 못했습니다. 다시 시도해 주세요.')),
      ),
    );
  }
}
