import '../error/failures.dart';

/// Lightweight Either: every repository call returns a [Result] instead of
/// throwing, which forces callers to handle the failure path explicitly.
sealed class Result<T> {
  const Result();

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T value) onSuccess,
  ) => switch (this) {
    Success<T>(:final value) => onSuccess(value),
    Err<T>(:final failure) => onFailure(failure),
  };

  bool get isSuccess => this is Success<T>;
  Failure? get failureOrNull => switch (this) {
    Err<T>(:final failure) => failure,
    _ => null,
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
