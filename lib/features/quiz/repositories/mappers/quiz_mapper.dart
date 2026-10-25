import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_difficulty_level.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/quiz_format_type.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/enums/question_cognitive_type.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/quiz_model.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_option_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_question_entity.dart';

extension QuizMapper on QuizModel {
  QuizEntity toEntity() {
    final orderedQuestions = [...questions]
      ..sort((a, b) => a.orderNo.compareTo(b.orderNo));
    if (orderedQuestions
            .map((question) => question.questionId)
            .toSet()
            .length !=
        orderedQuestions.length) {
      throw const FormatException('문제 정보가 올바르지 않습니다. 다시 불러와 주세요.');
    }
    return QuizEntity(
      quizId: quizId,
      materialId: materialId,
      format: switch (format) {
        QuizFormatType.multipleChoice => .multipleChoice,
        QuizFormatType.ox => .ox,
        QuizFormatType.$unknown => throw const FormatException(
          '지원하지 않는 문제 형식입니다.',
        ),
      },
      difficulty: switch (difficulty) {
        QuizDifficultyLevel.easy => .easy,
        QuizDifficultyLevel.normal => .normal,
        QuizDifficultyLevel.hard => .hard,
        QuizDifficultyLevel.$unknown => throw const FormatException(
          '지원하지 않는 난이도입니다.',
        ),
      },
      questions: List.unmodifiable(
        orderedQuestions.map((question) {
          final options = [...question.options]
            ..sort((a, b) => a.orderNo.compareTo(b.orderNo));
          if (options.isEmpty ||
              !options.any((option) => option.isCorrect) ||
              options.map((option) => option.optionId).toSet().length !=
                  options.length) {
            throw const FormatException('문제의 보기 또는 정답 정보가 없습니다. 다시 불러와 주세요.');
          }
          return QuizQuestionEntity(
            questionId: question.questionId,
            cognitiveType: switch (question.cognitiveType) {
              QuestionCognitiveType.remember => .remember,
              QuestionCognitiveType.understand => .understand,
              QuestionCognitiveType.apply => .apply,
              QuestionCognitiveType.analyze => .analyze,
              QuestionCognitiveType.evaluate => .evaluate,
              QuestionCognitiveType.$unknown => null,
            },
            content: question.content,
            conceptName: question.conceptName,
            explanation: question.explanation,
            sourceQuote: question.sourceQuote,
            sourcePageNo: question.sourcePageNo,
            options: List.unmodifiable(
              options.map(
                (option) => QuizOptionEntity(
                  optionId: option.optionId,
                  content: option.content,
                  isCorrect: option.isCorrect,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
