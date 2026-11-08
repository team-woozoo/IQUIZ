///
/// 자료 업로드·퀴즈 생성 진행 상태
///
enum QuizGenerationStatus {
  idle,
  uploading,
  pending,
  processing,
  done,
  failed;

  bool get isFinished => this == done || this == failed;

  bool get isBusy => switch (this) {
    uploading || pending || processing => true,
    _ => false,
  };
}
