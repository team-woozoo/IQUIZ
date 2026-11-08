import 'package:iquiz/features/config/data_source/remote/models/notice_detail_model.dart';

final class NoticeDetailEntity {
  const NoticeDetailEntity({required this.title, required this.description});
  factory NoticeDetailEntity.fromModel(NoticeDetailModel model) =>
      NoticeDetailEntity(title: model.title, description: model.description);

  final String title;
  final String description;
}
