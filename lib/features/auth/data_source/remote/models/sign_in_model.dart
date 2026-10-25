import 'package:json_annotation/json_annotation.dart';

part 'sign_in_model.g.dart';

///
/// 로그인 요청 정보
///
@JsonSerializable()
class SignInModel {
  const SignInModel({required this.email, required this.password});

  factory SignInModel.fromJson(Map<String, Object?> json) =>
      _$SignInModelFromJson(json);

  final String email;
  final String password;

  Map<String, Object?> toJson() => _$SignInModelToJson(this);
}
