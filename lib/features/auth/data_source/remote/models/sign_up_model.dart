import 'package:json_annotation/json_annotation.dart';

part 'sign_up_model.g.dart';

///
/// 회원가입 요청 정보
///
@JsonSerializable()
class SignUpModel {
  const SignUpModel({
    required this.email,
    required this.password,
    required this.nickname,
  });

  factory SignUpModel.fromJson(Map<String, Object?> json) =>
      _$SignUpModelFromJson(json);

  final String email;
  final String password;
  final String nickname;

  Map<String, Object?> toJson() => _$SignUpModelToJson(this);
}
