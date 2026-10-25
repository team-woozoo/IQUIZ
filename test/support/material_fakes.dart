import 'package:iquiz/features/quiz/repositories/entities/study_material_entity.dart';

Map<String, Object?> materialJson({int id = 1}) => {
  'materialId': id,
  'title': '네트워크',
  'originalFilename': 'network.pdf',
  'pageCount': 12,
  'createdAt': '2026-10-14T01:00:00Z',
  'questionCount': 10,
  'answeredCount': 2,
  'correctCount': 2,
  'wrongCount': 8,
  'accuracy': 0.2,
  'generating': true,
};

Map<String, Object?> materialConceptJson({String status = 'WEAK'}) => {
  'conceptId': 12,
  'conceptName': 'TCP 연결',
  'pageNos': [3, 4, 7],
  'questionCount': 10,
  'answeredCount': 2,
  'correctCount': 2,
  'accuracy': 0.2,
  'status': status,
};

StudyMaterialEntity testMaterial({int id = 1, int correctCount = 2}) =>
    StudyMaterialEntity(
      materialId: id,
      title: '네트워크',
      originalFilename: 'network.pdf',
      pageCount: 12,
      createdAt: DateTime.utc(2026, 10, 14, 1),
      questionCount: 10,
      answeredCount: 2,
      correctCount: correctCount,
      wrongCount: 10 - correctCount,
      accuracy: correctCount / 10,
      generating: false,
    );
