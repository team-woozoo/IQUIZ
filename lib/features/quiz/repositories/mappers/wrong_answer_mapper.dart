import 'package:iquiz/features/quiz/data_source/remote/enums/wrong_answer_cognitive_type.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/wrong_answer_format.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/wrong_answer_model.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_option_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/wrong_answer_entity.dart';

extension WrongAnswerMapper on WrongAnswerModel {
  WrongAnswerEntity toEntity() {
    final orderedOptions = [...options]
      ..sort((a, b) => a.orderNo.compareTo(b.orderNo));
    if (questionId <= 0 ||
        quizId <= 0 ||
        materialId <= 0 ||
        wrongCount < 0 ||
        (sourcePageNo != null && sourcePageNo! <= 0) ||
        orderedOptions.isEmpty ||
        orderedOptions.any((option) => option.optionId <= 0) ||
        !orderedOptions.any((option) => option.isCorrect) ||
        orderedOptions.map((option) => option.optionId).toSet().length !=
            orderedOptions.length) {
      throw const FormatException('오답 문제 또는 보기 정보가 올바르지 않습니다.');
    }
    return WrongAnswerEntity(
      questionId: questionId,
      quizId: quizId,
      format: switch (format) {
        WrongAnswerFormat.multipleChoice => .multipleChoice,
        WrongAnswerFormat.ox => .ox,
        WrongAnswerFormat.$unknown => throw const FormatException(
          '지원하지 않는 문제 형식입니다.',
        ),
      },
      content: content,
      cognitiveType: switch (cognitiveType) {
        WrongAnswerCognitiveType.remember => .remember,
        WrongAnswerCognitiveType.understand => .understand,
        WrongAnswerCognitiveType.apply => .apply,
        WrongAnswerCognitiveType.analyze => .analyze,
        WrongAnswerCognitiveType.evaluate => .evaluate,
        WrongAnswerCognitiveType.$unknown => throw const FormatException(
          '지원하지 않는 인지 유형입니다.',
        ),
      },
      conceptName: conceptName,
      materialId: materialId,
      materialTitle: materialTitle,
      explanation: explanation,
      sourceQuote: sourceQuote,
      sourcePageNo: sourcePageNo,
      options: List.unmodifiable(
        orderedOptions.map(
          (option) => QuizOptionEntity(
            optionId: option.optionId,
            content: option.content,
            isCorrect: option.isCorrect,
          ),
        ),
      ),
      wrongCount: wrongCount,
      lastWrongAt: lastWrongAt,
    );
  }
}
