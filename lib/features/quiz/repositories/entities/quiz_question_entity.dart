import 'package:iquiz/features/quiz/repositories/entities/quiz_option_entity.dart';
import 'package:iquiz/features/learning_profile/repositories/enums/cognitive_type.enum.dart';

final class QuizQuestionEntity {
  const QuizQuestionEntity({
    required this.questionId,
    required this.content,
    required this.conceptName,
    required this.explanation,
    required this.sourceQuote,
    required this.sourcePageNo,
    required this.options,
    this.cognitiveType,
  });

  final int questionId;
  final String content;
  final String conceptName;
  final String explanation;
  final String sourceQuote;
  final int? sourcePageNo;
  final List<QuizOptionEntity> options;
  final CognitiveType? cognitiveType;

  bool get allowsMultipleAnswers =>
      options.where((option) => option.isCorrect).length > 1;

  bool isCorrectOption(int? optionId) =>
      options.any((option) => option.optionId == optionId && option.isCorrect);

  bool isCorrect(Set<int> selectedIds) {
    final correctIds = options
        .where((option) => option.isCorrect)
        .map((option) => option.optionId)
        .toSet();
    return correctIds.isNotEmpty &&
        selectedIds.length == correctIds.length &&
        selectedIds.containsAll(correctIds);
  }
}
