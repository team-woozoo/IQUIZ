import 'package:json_annotation/json_annotation.dart';

part 'material_upload_result_model.g.dart';

///
/// 학습 자료 업로드 결과
///
@JsonSerializable()
class MaterialUploadResultModel {
  const MaterialUploadResultModel({required this.materialId});

  factory MaterialUploadResultModel.fromJson(Map<String, Object?> json) =>
      _$MaterialUploadResultModelFromJson(json);

  final int materialId;

  Map<String, Object?> toJson() => _$MaterialUploadResultModelToJson(this);
}
