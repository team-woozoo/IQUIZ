part of '../splash_page.dart';

class _SplashFailure extends StatelessWidget {
  const _SplashFailure({
    required this.message,
    required this.onRetry,
    required this.onSignInAgain,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSignInAgain;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
          TextButton(onPressed: onSignInAgain, child: const Text('다시 로그인')),
        ],
      ),
    ),
  );
}
