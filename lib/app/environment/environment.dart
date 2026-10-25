import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:iquiz/app/firebase/firebase_options_dev.dart' as dev_firebase;
import 'package:iquiz/app/firebase/firebase_options_prod.dart' as prod_firebase;

enum Environment(final String type) {
  dev('DEV'),
  prod('PROD');

  String get dotFileName => '.env';

  String get baseUrl => switch (this) {
    dev => dotenv.env['BASE_DEV_URL']!,
    prod => dotenv.env['BASE_PROD_URL']!,
  };

  FirebaseOptions get firebaseOption => switch (this) {
    prod => prod_firebase.DefaultFirebaseOptions.currentPlatform,
    dev => dev_firebase.DefaultFirebaseOptions.currentPlatform,
  };
}
