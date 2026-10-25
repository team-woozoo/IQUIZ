import 'package:json_annotation/json_annotation.dart';

part 'sign_up_result_model.g.dart';

///
/// 회원가입 결과
///
@JsonSerializable()
class SignUpResultModel {
  const SignUpResultModel({required this.id});

  factory SignUpResultModel.fromJson(Map<String, Object?> json) =>
      _$SignUpResultModelFromJson(json);

  final int id;

  Map<String, Object?> toJson() => _$SignUpResultModelToJson(this);
}
