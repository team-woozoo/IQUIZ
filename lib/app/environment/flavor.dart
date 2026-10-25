import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'environment.dart';

class Flavor {
  Flavor._();

  static final Flavor _instance = Flavor._();

  static Flavor get instance => _instance;

  Environment _env = Environment.prod;

  Environment get env => _env;

  Future<void> setup(Environment environment) async {
    debugInvertOversizedImages = true;
    WidgetsFlutterBinding.ensureInitialized();
    // 시스템 제스처 영역확장
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    await dotenv.load(fileName: environment.dotFileName);
    _env = environment;

    // firebase 초기화
    await Firebase.initializeApp(options: _env.firebaseOption);
  }
}
