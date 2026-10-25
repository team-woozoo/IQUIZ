import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/di/auth/auth.dart';
import 'package:iquiz/app/environment/environment.dart';
import 'package:iquiz/app/environment/flavor.dart';
import 'package:iquiz/app/network/app_dio.dart';

/// 설정을 읽는 상위 계층에서 주소를 전달하고 여기서 인증 구현을 연결
final initializeNetworkProvider = Provider.family<void, String>((ref, baseUrl) {
  AppDio.initialize(
    baseUrl: baseUrl,
    session: ref.watch(authTokenManagerProvider),
    allowInsecureHttp: kDebugMode && Flavor.instance.env == Environment.dev,
  );
});
