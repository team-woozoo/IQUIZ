import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract final class PageRouting {
  static void go(WidgetRef ref, GoRouteData pageRoute) {
    final context = ref.context;

    if (!context.mounted) return;

    pageRoute.go(context);
  }
}
