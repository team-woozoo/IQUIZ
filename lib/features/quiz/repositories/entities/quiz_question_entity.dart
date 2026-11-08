import 'package:iquiz/features/learning_profile/repositories/enums/cognitive_type.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/question_cognitive_type.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/quiz_question_model.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_option_entity.dart';

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

  factory QuizQuestionEntity.fromModel(QuizQuestionModel model) {
    final options = [...model.options]
      ..sort((a, b) => a.orderNo.compareTo(b.orderNo));
    if (options.isEmpty ||
        !options.any((option) => option.isCorrect) ||
        options.map((option) => option.optionId).toSet().length !=
            options.length) {
      throw const FormatException('문제의 보기 또는 정답 정보가 없습니다. 다시 불러와 주세요.');
    }
    return QuizQuestionEntity(
      questionId: model.questionId,
      cognitiveType: switch (model.cognitiveType) {
        QuestionCognitiveType.remember => .remember,
        QuestionCognitiveType.understand => .understand,
        QuestionCognitiveType.apply => .apply,
        QuestionCognitiveType.analyze => .analyze,
        QuestionCognitiveType.evaluate => .evaluate,
        QuestionCognitiveType.$unknown => null,
      },
      content: model.content,
      conceptName: model.conceptName,
      explanation: model.explanation,
      sourceQuote: model.sourceQuote,
      sourcePageNo: model.sourcePageNo,
      options: List.unmodifiable(options.map(QuizOptionEntity.fromModel)),
    );
  }

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
