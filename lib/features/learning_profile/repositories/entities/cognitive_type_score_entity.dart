import 'package:iquiz/features/learning_profile/repositories/enums/cognitive_type.enum.dart';

final class CognitiveTypeScoreEntity {
  const CognitiveTypeScoreEntity({
    required this.cognitiveType,
    required this.answeredCount,
    required this.correctAnswerCount,
    required this.accuracy,
    required this.isEnoughData,
  });

  final CognitiveType cognitiveType;
  final int answeredCount;
  final int correctAnswerCount;

  /// 0~1 범위이며, 이 유형을 풀지 않았으면 null
  final double? accuracy;

  /// 서버가 판단한 집계 데이터 충분성
  final bool isEnoughData;
}
