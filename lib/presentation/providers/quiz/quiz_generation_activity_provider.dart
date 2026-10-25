import 'package:flutter/foundation.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_generation_status.enum.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quiz_generation_activity_provider.g.dart';

final class QuizGenerationActivityEntry {
  const QuizGenerationActivityEntry({
    required this.id,
    required this.title,
    required this.status,
  });

  final int id;
  final String title;
  final QuizGenerationStatus status;
}

/// 앱에서 진행 중인 작업만 보관하며, 계정 변경 시 기존 작업의 보관을 해제
@Riverpod(keepAlive: true)
class QuizGenerationActivity extends _$QuizGenerationActivity {
  int _nextId = 0;
  final _release = <int, VoidCallback>{};
  final _stopListening = <int, VoidCallback>{};

  @override
  List<QuizGenerationActivityEntry> build() {
    ref.watch(userAuthProvider.select((auth) => auth.user?.id));
    ref.onDispose(() {
      final callbacks = _release.values.toList();
      final subscriptions = _stopListening.values.toList();
      _release.clear();
      _stopListening.clear();
      for (final stop in subscriptions) {
        stop();
      }
      for (final release in callbacks) {
        release();
      }
    });
    return const [];
  }

  int start({required String title, required VoidCallback release}) {
    final id = _nextId++;
    _release[id] = release;
    state = [
      QuizGenerationActivityEntry(id: id, title: title, status: .uploading),
      ...state,
    ];
    return id;
  }

  bool contains(int id) => _release.containsKey(id);

  /// 홈에서 관찰하는 동안 업로드 페이지가 사라져도 스트림이 일시 정지되지 않게 처리
  void retain<T>(int id, ProviderListenable<T> provider) {
    _stopListening[id] = ref.listen(provider, (_, _) {}).close;
  }

  void update(int id, QuizGenerationStatus status) {
    if (!contains(id)) return;
    state = [
      for (final entry in state)
        if (entry.id == id)
          QuizGenerationActivityEntry(
            id: id,
            title: entry.title,
            status: status,
          )
        else
          entry,
    ];
  }

  void finish(int id) {
    if (_release.remove(id) == null) return;
    _stopListening.remove(id)?.call();
    state = [
      for (final entry in state)
        if (entry.id != id) entry,
    ];
  }
}
