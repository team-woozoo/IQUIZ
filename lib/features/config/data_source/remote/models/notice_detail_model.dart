import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'notice_detail_model.g.dart';

///
/// 공지 상세 항목
///
@JsonSerializable(fieldRename: .snake, createToJson: false)
class NoticeDetailModel {
  const NoticeDetailModel({required this.title, required this.description});

  final String title;
  final String description;

  factory NoticeDetailModel.fromJson(Map<String, dynamic> json) =>
      _$NoticeDetailModelFromJson(json);

  static List<NoticeDetailModel> listFromJsonString(String value) {
    if (value.trim().isEmpty) return const [];

    return (jsonDecode(value) as List<dynamic>)
        .map((json) => NoticeDetailModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
