import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'log.dart';

final class LogObserver extends ProviderObserver {
  const LogObserver();

  void _write(String event, ProviderObserverContext context) {
    final name = context.provider.name ?? context.provider.runtimeType;

    Log.t(
      '[Provider $event] : $name\n'
      '[Container] : ${context.container}',
    );
  }

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) =>
      _write('Init', context);

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) => _write('Update', context);

  @override
  void didDisposeProvider(ProviderObserverContext context) =>
      _write('Dispose', context);
}
