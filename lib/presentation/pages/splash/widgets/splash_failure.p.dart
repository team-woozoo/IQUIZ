part of '../splash_page.dart';

class _SplashFailure extends ConsumerWidget with SplashEvent {
  const _SplashFailure();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '로그인 상태를 확인하지 못했습니다.\n네트워크 연결을 확인해 주세요.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => routePage(ref),
            child: const Text('다시 시도'),
          ),
          TextButton(
            onPressed: () => onSignInAgain(ref),
            child: const Text('다시 로그인'),
          ),
        ],
      ),
    ),
  );
}
