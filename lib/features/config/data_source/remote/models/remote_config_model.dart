import 'dart:convert';

import 'package:iquiz/features/config/data_source/remote/models/notice_detail_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'remote_config_model.g.dart';

///
/// 원격 앱 설정 정보
///
@JsonSerializable(
  explicitToJson: true,
  fieldRename: .snake,
  createToJson: false,
)
class RemoteConfigModel {
  const RemoteConfigModel({
    required this.title,
    required this.description,
    required this.details,
    required this.enabled,
    required this.minBuildNumber,
    required this.noticeUrl,
    required this.baseUrl,
    required this.minVersion,
  });

  final bool enabled;
  final String minVersion;
  final int minBuildNumber;
  final Uri noticeUrl;
  final String baseUrl;
  final String title;
  final String description;
  final List<NoticeDetailModel> details;

  factory RemoteConfigModel.fromJson(Map<String, dynamic> json) =>
      _$RemoteConfigModelFromJson(json);

  factory RemoteConfigModel.fromJsonString(String value) {
    return RemoteConfigModel.fromJson(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }
}
