part of 'quiz_result_page.dart';

typedef QuizConceptResult = ({
  String name,
  int questionCount,
  List<int> pages,
  int wrong,
  int unchecked,
});

mixin class QuizResultState {
  QuizResultRouteArg? resultData(WidgetRef ref) =>
      ref.watch(quizResultRouteArgProvider);

  List<QuizConceptResult> conceptResults(QuizResultRouteArg data) {
    final correct = {
      for (final result in data.submission.results)
        result.questionId: result.correct,
    };
    final answered = data.answers.map((answer) => answer.questionId).toSet();
    final grouped = <String, List<QuizQuestionEntity>>{};
    for (final question in data.quiz.questions) {
      final name = question.conceptName.trim();
      grouped
          .putIfAbsent(name.isEmpty ? '기타 개념' : name, () => [])
          .add(question);
    }
    final result = [
      for (final entry in grouped.entries)
        (
          name: entry.key,
          questionCount: entry.value.length,
          pages: {
            for (final question in entry.value)
              if (question.sourcePageNo != null) question.sourcePageNo!,
          }.toList()..sort(),
          wrong: entry.value
              .where(
                (question) =>
                    answered.contains(question.questionId) &&
                    correct[question.questionId] != true,
              )
              .length,
          unchecked: entry.value
              .where((question) => !answered.contains(question.questionId))
              .length,
        ),
    ];
    result.sort((a, b) {
      final wrongOrder = b.wrong.compareTo(a.wrong);
      if (wrongOrder != 0) return wrongOrder;
      return (a.pages.firstOrNull ?? 0).compareTo(b.pages.firstOrNull ?? 0);
    });
    return result;
  }

  String pagesLabel(List<int> pages) {
    if (pages.isEmpty) return '페이지 정보 없음';
    final parts = <String>[];
    var start = pages.first;
    var end = start;
    for (final page in pages.skip(1)) {
      if (page == end + 1) {
        end = page;
      } else {
        parts.add(start == end ? '$start' : '$start~$end');
        start = end = page;
      }
    }
    parts.add(start == end ? '$start' : '$start~$end');
    return 'PDF ${parts.join(', ')} 페이지';
  }

  ({String title, String message}) insight(QuizResultRouteArg data) {
    final wrong = data.submission.results
        .where((result) => !result.correct)
        .map((result) => result.questionId)
        .toSet();
    if (wrong.isEmpty) {
      return (title: '모든 문제를 정확히 풀었어요', message: '잘 이해한 내용을 다른 문제에도 적용해 보세요.');
    }
    final counts = <CognitiveType, int>{};
    for (final question in data.quiz.questions) {
      final type = question.cognitiveType;
      if (type != null && wrong.contains(question.questionId)) {
        counts.update(type, (count) => count + 1, ifAbsent: () => 1);
      }
    }
    if (counts.isEmpty) {
      return (
        title: '틀린 개념을 다시 확인해 보세요',
        message: '문제의 해설과 PDF 근거를 살펴보며 복습해 보세요.',
      );
    }
    final entries = counts.entries.toList()
      ..sort(
        (a, b) => b.value != a.value
            ? b.value.compareTo(a.value)
            : a.key.index.compareTo(b.key.index),
      );
    return switch (entries.first.key) {
      CognitiveType.remember => (
        title: '기억 문제를 많이 틀렸어요',
        message: '핵심 용어와 개념을 다시 떠올리는 연습을 해보세요',
      ),
      CognitiveType.understand => (
        title: '이해 문제를 많이 틀렸어요',
        message: '배운 개념을 자신의 말로 설명해 보세요',
      ),
      CognitiveType.apply => (
        title: '응용 문제를 많이 틀렸어요',
        message: '배운 내용을 실제 상황에 대입해 보는 연습을 해보세요',
      ),
      CognitiveType.analyze => (
        title: '분석 문제를 많이 틀렸어요',
        message: '개념 사이의 차이와 관계를 비교해 보세요',
      ),
      CognitiveType.evaluate => (
        title: '평가 문제를 많이 틀렸어요',
        message: '판단의 근거와 기준을 함께 살펴보세요',
      ),
    };
  }
}
