abstract class Result<T> {
  static Result<T> failure<T>(Exception error) => Failure<T>(error);

  static Result<T> success<T>(T value) => Success<T>(value);

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Exception e) onFailure,
  }) {
    if (this case final Success<T> success) {
      return onSuccess(success.value);
    }
    if (this case final Failure<T> failure) {
      return onFailure(failure.error);
    }

    throw StateError('Unknown Result subtype: $runtimeType');
  }
}

class Success<T> extends Result<T> {
  final T value;

  Success(this.value);
}

class Failure<T> extends Result<T> {
  final Exception error;

  Failure(this.error);
}
