final class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.nickname,
  });

  final int id;
  final String email;
  final String nickname;

  @override
  String toString() => 'AuthUser(id: $id)';
}
