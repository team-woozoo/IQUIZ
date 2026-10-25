import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/environment/environment.dart';
import 'package:iquiz/app/environment/flavor.dart';
import 'package:iquiz/app/router/router_state.dart';
import 'package:iquiz/app/style/app_theme.dart';
import 'package:iquiz/core/logger/log_observer.dart';
import 'package:iquiz/core/services/app_size.dart';

final globalContainer = ProviderContainer(observers: [const LogObserver()]);
Future<void> main() async {
  await Flavor.instance.setup(Environment.dev);
  runapp();
}

void runapp() {
  runApp(
    UncontrolledProviderScope(container: globalContainer, child: const App()),
  );
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerStateProvider),
      builder: (context, child) {
        AppSize.init(context);
        return child!;
      },
    );
  }
}
