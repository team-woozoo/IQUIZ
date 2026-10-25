// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RemoteConfigModel _$RemoteConfigModelFromJson(Map<String, dynamic> json) =>
    RemoteConfigModel(
      title: json['title'] as String,
      description: json['description'] as String,
      details: (json['details'] as List<dynamic>)
          .map((e) => NoticeDetailModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      enabled: json['enabled'] as bool,
      minBuildNumber: (json['min_build_number'] as num).toInt(),
      noticeUrl: Uri.parse(json['notice_url'] as String),
      baseUrl: json['base_url'] as String,
      minVersion: json['min_version'] as String,
    );
