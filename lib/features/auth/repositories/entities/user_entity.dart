import 'package:iquiz/features/auth/data_source/remote/models/user_model.dart';

final class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.nickname,
  });

  factory UserEntity.fromModel(UserModel model) =>
      UserEntity(id: model.id, email: model.email, nickname: model.nickname);

  final int id;
  final String email;
  final String nickname;

  @override
  String toString() => 'AuthUser(id: $id)';
}
