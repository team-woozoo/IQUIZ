import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iquiz/features/auth/data_source/local/auth_local_data_source_impl.dart';

import '../../support/auth_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();
  const dev = AuthLocalDataSourceImpl(
    storage: storage,
    key: 'iquiz.dev.auth.tokens',
  );
  const prod = AuthLocalDataSourceImpl(
    storage: storage,
    key: 'iquiz.prod.auth.tokens',
  );
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('두 토큰을 함께 저장·복원하고 dev 삭제가 prod 세션에 영향을 주지 않는다', () async {
    await dev.write(testTokens('dev'));
    await prod.write(testTokens('prod'));
    expect((await dev.read())?.accessToken, 'access-dev');
    expect((await dev.read())?.refreshToken, 'refresh-dev');
    expect((await dev.read())?.expiresAt.isUtc, isTrue);
    await dev.delete();
    expect(await dev.read(), isNull);
    expect((await prod.read())?.refreshToken, 'refresh-prod');
  });

  test('손상된 저장 데이터는 삭제하고 비로그인으로 복원한다', () async {
    await storage.write(key: dev.key, value: '{bad json');
    expect(await dev.read(), isNull);
    expect(await storage.read(key: dev.key), isNull);
  });
}
