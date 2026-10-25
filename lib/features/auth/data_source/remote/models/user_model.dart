import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

///
/// 유저 정보
///
@JsonSerializable()
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.nickname,
  });

  factory UserModel.fromJson(Map<String, Object?> json) =>
      _$UserModelFromJson(json);

  final int id;
  final String email;
  final String nickname;

  Map<String, Object?> toJson() => _$UserModelToJson(this);
}
