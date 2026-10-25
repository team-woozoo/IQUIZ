import 'package:iquiz/main.dart';

import 'app/environment/environment.dart';
import 'app/environment/flavor.dart';

Future<void> main() async {
  await Flavor.instance.setup(Environment.dev);
  return runapp();
}
