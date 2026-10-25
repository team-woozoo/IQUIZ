import 'package:logger/logger.dart';

abstract final class Log {
  static final _logger = Logger();

  static final t = _logger.t;
  static final d = _logger.d;
  static final i = _logger.i;
  static final w = _logger.w;
  static final e = _logger.e;
  static final f = _logger.f;
}
