import 'package:iquiz/features/learning_profile/repositories/enums/cognitive_type.enum.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_option_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_format.enum.dart';

/// 미해결 오답. materialId는 개념이 나온 원본 자료 ID
final class WrongAnswerEntity {
  const WrongAnswerEntity({
    required this.questionId,
    required this.quizId,
    required this.format,
    required this.content,
    required this.cognitiveType,
    required this.conceptName,
    required this.materialId,
    required this.materialTitle,
    required this.explanation,
    required this.sourceQuote,
    required this.sourcePageNo,
    required this.options,
    required this.wrongCount,
    required this.lastWrongAt,
  });

  final int questionId;
  final int quizId;
  final QuizFormat format;
  final String content;
  final CognitiveType cognitiveType;
  final String conceptName;
  final int materialId;
  final String materialTitle;
  final String explanation;
  final String sourceQuote;
  final int? sourcePageNo;
  final List<QuizOptionEntity> options;
  final int wrongCount;
  final DateTime lastWrongAt;
}
