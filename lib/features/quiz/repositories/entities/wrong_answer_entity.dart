import 'package:iquiz/features/learning_profile/repositories/enums/cognitive_type.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/wrong_answer_cognitive_type.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/wrong_answer_format.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/wrong_answer_model.dart';
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

  factory WrongAnswerEntity.fromModel(WrongAnswerModel model) {
    final orderedOptions = [...model.options]
      ..sort((a, b) => a.orderNo.compareTo(b.orderNo));
    final validIds =
        model.questionId > 0 && model.quizId > 0 && model.materialId > 0;
    final validHistory =
        model.wrongCount >= 0 &&
        (model.sourcePageNo == null || model.sourcePageNo! > 0);
    final validOptions =
        orderedOptions.every((option) => option.optionId > 0) &&
        orderedOptions.any((option) => option.isCorrect) &&
        orderedOptions.map((option) => option.optionId).toSet().length ==
            orderedOptions.length;

    if (!validIds || !validHistory || !validOptions) {
      throw const FormatException('오답 문제 또는 보기 정보가 올바르지 않습니다.');
    }
    return WrongAnswerEntity(
      questionId: model.questionId,
      quizId: model.quizId,
      format: switch (model.format) {
        WrongAnswerFormat.multipleChoice => .multipleChoice,
        WrongAnswerFormat.ox => .ox,
        WrongAnswerFormat.$unknown => throw const FormatException(
          '지원하지 않는 문제 형식입니다.',
        ),
      },
      content: model.content,
      cognitiveType: switch (model.cognitiveType) {
        WrongAnswerCognitiveType.remember => .remember,
        WrongAnswerCognitiveType.understand => .understand,
        WrongAnswerCognitiveType.apply => .apply,
        WrongAnswerCognitiveType.analyze => .analyze,
        WrongAnswerCognitiveType.evaluate => .evaluate,
        WrongAnswerCognitiveType.$unknown => throw const FormatException(
          '지원하지 않는 인지 유형입니다.',
        ),
      },
      conceptName: model.conceptName,
      materialId: model.materialId,
      materialTitle: model.materialTitle,
      explanation: model.explanation,
      sourceQuote: model.sourceQuote,
      sourcePageNo: model.sourcePageNo,
      options: List.unmodifiable(
        orderedOptions.map(QuizOptionEntity.fromModel),
      ),
      wrongCount: model.wrongCount,
      lastWrongAt: model.lastWrongAt,
    );
  }

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
