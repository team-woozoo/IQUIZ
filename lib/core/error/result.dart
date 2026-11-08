sealed class Result<T> {
  static Result<T> failure<T>(Exception error) => Failure<T>(error);

  static Result<T> success<T>(T value) => Success<T>(value);

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Exception e) onFailure,
  }) => switch (this) {
    Success<T>(:final value) => onSuccess(value),
    Failure<T>(:final error) => onFailure(error),
  };

  /// 성공 값을 꺼내고, 실패는 호출부의 오류 처리로 전달
  T getOrThrow() => switch (this) {
    Success<T>(:final value) => value,
    Failure<T>(:final error) => throw error,
  };
}

final class Success<T> extends Result<T> {
  final T value;

  Success(this.value);
}

final class Failure<T> extends Result<T> {
  final Exception error;

  Failure(this.error);
}
