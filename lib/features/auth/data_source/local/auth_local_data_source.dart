import 'package:iquiz/features/auth/repositories/entities/jwt_entity.dart';

abstract interface class AuthLocalDataSource {
  Future<JwtEntity?> read();
  Future<void> write(JwtEntity tokens);
  Future<void> delete();
}
