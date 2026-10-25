import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/presentation/pages/splash/splash_page.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';
import 'package:iquiz/presentation/pages/splash/providers/splash_animation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('prod/dev 런처는 흰색 1024px이며 DEV 디자인이 다르다', () async {
    final pixels = <ByteData>[];
    for (final flavor in ['prod', 'dev']) {
      final codec = await ui.instantiateImageCodec(
        File('assets/branding/iquiz_${flavor}_launcher.png').readAsBytesSync(),
      );
      final image = (await codec.getNextFrame()).image;
      expect(image.width, 1024);
      expect(image.height, 1024);
      final data = (await image.toByteData())!;
      for (var i = 3; i < data.lengthInBytes; i += 4) {
        expect(data.getUint8(i), 255);
      }
      expect(data.getUint32(0), 0xFFFFFFFF);
      pixels.add(data);
      image.dispose();
      codec.dispose();
    }
    expect(
      pixels[0].buffer.asUint8List(),
      isNot(equals(pixels[1].buffer.asUint8List())),
    );
  });

  test('Android 12 로고는 원형 안전 영역 안에 있다', () async {
    final codec = await ui.instantiateImageCodec(
      File('assets/branding/iquiz_splash_android12.png').readAsBytesSync(),
    );
    final image = (await codec.getNextFrame()).image;
    final rgba = (await image.toByteData())!;
    var maxRadius = 0.0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        if (rgba.getUint8((y * image.width + x) * 4 + 3) > 16) {
          maxRadius = math.max(
            maxRadius,
            math.sqrt(math.pow(x - 576, 2) + math.pow(y - 576, 2)),
          );
        }
      }
    }
    expect(maxRadius, lessThanOrEqualTo(384));
    image.dispose();
    codec.dispose();
  });

  testWidgets('Lottie의 재생 시간과 마지막 로고 프레임을 검증한다', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final composition = (await tester.runAsync(
      () => AssetLottie('assets/lottie/iquiz_splash.json').load(),
    ))!;
    expect(composition.duration, const Duration(milliseconds: 4400));
    expect(
      composition.images.values.every((image) => image.loadedImage != null),
      isTrue,
    );
    final boundary = GlobalKey<State<StatefulWidget>>();
    Future<Uint8List> frame(double progress) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ColoredBox(
            color: Colors.white,
            child: RepaintBoundary(
              key: boundary,
              child: Lottie(
                composition: composition,
                controller: AlwaysStoppedAnimation(progress),
                frameRate: FrameRate.max,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final render =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      return (await tester.runAsync(() async {
        final image = await render.toImage();
        final data = (await image.toByteData())!.buffer.asUint8List();
        if (Platform.environment['UPDATE_BRAND_PREVIEWS'] == '1') {
          final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
          final output = File(
            'build/branding/flutter-${(progress * composition.duration.inMilliseconds).round()}.png',
          );
          output.parent.createSync(recursive: true);
          output.writeAsBytesSync(png.buffer.asUint8List());
        }
        image.dispose();
        return data;
      }))!;
    }

    final start = await frame(0);
    final peak = await frame(620 / composition.duration.inMilliseconds);
    expect(start, isNot(equals(peak)));
    final end = await frame(1);
    expect(end, isNot(equals(start)));
    expect(tester.takeException(), isNull);
  });

  testWidgets('스플래시는 에셋 길이만큼 한 번 재생한 뒤 마지막 프레임을 유지한다', (tester) async {
    final composition = (await tester.runAsync(
      () => AssetLottie('assets/lottie/iquiz_splash.json').load(),
    ))!;
    final container = ProviderContainer(
      overrides: [userAuthProvider.overrideWith(_PreviewAuth.new)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: _PreviewSplash()),
      ),
    );
    await tester.pump();
    await tester.pump();
    final lottie = tester.widget<LottieBuilder>(find.byType(LottieBuilder));
    expect(lottie.lottie, isA<AssetLottie>());
    expect(
      (lottie.lottie as AssetLottie).assetName,
      'assets/lottie/iquiz_splash.json',
    );
    final controller = lottie.controller! as AnimationController;
    expect(controller.duration, composition.duration);
    expect(lottie.repeat, isFalse);
    await tester.pump(composition.duration - const Duration(milliseconds: 1));
    expect(container.read(splashAnimationProvider), isFalse);
    await tester.pump(const Duration(milliseconds: 2));
    expect(container.read(splashAnimationProvider), isTrue);
    expect(controller.value, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(controller.value, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

// 브랜딩 검증은 Firebase/보안 저장소와 실제 세션 복원을 실행하지 않음
class _PreviewSplash extends SplashPage {
  const _PreviewSplash();
  @override
  void onReady(WidgetRef ref) {}
}

class _PreviewAuth extends UserAuth {
  @override
  UserAuthState build() => const UserAuthState(AuthStatus.initializing);
}
