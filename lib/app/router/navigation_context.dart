import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:iquiz/app/router/router_state.dart';
import 'package:iquiz/core/logger/log.dart';

Future<BuildContext> get navigationContext async {
  var context = rootNavigatorKey.currentContext;
  if (context != null) return context;

  final completer = Completer<BuildContext>();
  var retries = 0;
  const maxRetries = 30;
  const delay = Duration(milliseconds: 16);

  // 재귀적으로 Context를 확인
  void checkContext() {
    // 이미 완료되었다면 종료
    if (completer.isCompleted) return;

    context = rootNavigatorKey.currentContext;

    if (context != null) {
      // 찾았으면 완료 처리
      completer.complete(context);
    } else if (retries < maxRetries) {
      // 못 찾았고 횟수가 남았다면 재시도
      retries++;
      // 다음 프레임 이후에 다시 확인하도록 스케줄링
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        await Future<void>.delayed(delay);
        checkContext();
      });
    } else {
      completer.completeError(
        TimeoutException('rootNavigatorKey에서 BuildContext를 찾을 수 없습니다.'),
      );
    }
  }

  SchedulerBinding.instance.addPostFrameCallback((_) {
    checkContext();
  });

  return completer.future.catchError((Object error, StackTrace stackTrace) {
    Log.f('Context 조회 실패: $error');
    Error.throwWithStackTrace(error, stackTrace);
  });
}
