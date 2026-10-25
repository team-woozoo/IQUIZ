import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iquiz/features/auth/data_source/local/auth_local_data_source.dart';
import 'package:iquiz/features/auth/repositories/entities/jwt_entity.dart';

final class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl({required this.storage, required this.key});

  final FlutterSecureStorage storage;
  final String key;

  @override
  Future<JwtEntity?> read() async {
    final value = await storage.read(key: key);
    if (value == null) return null;
    try {
      return JwtEntity.fromStorage(jsonDecode(value) as Map<String, dynamic>);
    } on FormatException {
      await delete();
      return null;
    } on TypeError {
      await delete();
      return null;
    }
  }

  @override
  Future<void> write(JwtEntity tokens) =>
      storage.write(key: key, value: jsonEncode(tokens.toJson()));

  @override
  Future<void> delete() => storage.delete(key: key);
}
