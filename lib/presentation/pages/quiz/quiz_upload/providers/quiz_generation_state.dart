import 'package:dio/dio.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_generation_status.enum.dart';

final class QuizGenerationState {
  const QuizGenerationState({
    this.status = QuizGenerationStatus.idle,
    this.jobId,
    this.quizId,
    this.error,
  });

  final QuizGenerationStatus status;
  final int? jobId;
  final int? quizId;
  final Exception? error;

  String get title => switch (status) {
    QuizGenerationStatus.idle => '어떤 퀴즈를 만들까요?',
    QuizGenerationStatus.uploading => '학습 자료를 업로드하고 있어요',
    QuizGenerationStatus.pending => '퀴즈 생성 순서를 기다리고 있어요',
    QuizGenerationStatus.processing => '퀴즈를 만들고 있어요',
    QuizGenerationStatus.done => '퀴즈가 준비됐어요!',
    QuizGenerationStatus.failed => '퀴즈 생성을 완료하지 못했어요',
  };

  String get message => switch (status) {
    QuizGenerationStatus.idle => '난이도와 문제 유형을 고른 뒤 PDF를 업로드해 주세요.',
    QuizGenerationStatus.uploading => 'PDF를 업로드하고 학습 자료를 준비하고 있어요.',
    QuizGenerationStatus.pending => '생성 요청이 접수됐어요. 잠시만 기다려 주세요.',
    QuizGenerationStatus.processing => '자료를 바탕으로 문제와 해설을 만들고 있어요.',
    QuizGenerationStatus.done => '퀴즈 풀기 버튼을 눌러 문제를 풀어 보세요.',
    QuizGenerationStatus.failed => switch (error) {
      CustomException(:final detail) => detail,
      DioException(
        type: DioExceptionType.connectionTimeout ||
            DioExceptionType.receiveTimeout ||
            DioExceptionType.sendTimeout ||
            DioExceptionType.connectionError,
      ) =>
        '네트워크 연결을 확인하고 다시 시도해 주세요.',
      _ => '퀴즈 생성에 실패했어요. 잠시 후 다시 시도해 주세요.',
    },
  };

  String get buttonLabel => switch (status) {
    QuizGenerationStatus.idle => 'PDF 선택 후 업로드',
    QuizGenerationStatus.uploading => 'PDF 업로드 중...',
    QuizGenerationStatus.pending => '퀴즈 생성 대기 중...',
    QuizGenerationStatus.processing => '퀴즈 생성 중...',
    QuizGenerationStatus.done => '다른 PDF로 퀴즈 만들기',
    QuizGenerationStatus.failed => 'PDF 다시 선택하기',
  };

  bool get isBusy => switch (status) {
    QuizGenerationStatus.uploading ||
    QuizGenerationStatus.pending ||
    QuizGenerationStatus.processing => true,
    _ => false,
  };
}
