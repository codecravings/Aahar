import 'failures.dart';

/// Functional result type for error handling without exceptions
sealed class Result<T> {
  const Result();

  /// Create a success result
  factory Result.success(T data) = Success<T>;

  /// Create a failure result
  factory Result.failure(Failure failure) = Error<T>;

  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Error<T>;

  /// Get data if success, null otherwise
  T? get dataOrNull => switch (this) {
        Success(:final data) => data,
        Error() => null,
      };

  /// Get failure if error, null otherwise
  Failure? get failureOrNull => switch (this) {
        Success() => null,
        Error(:final failure) => failure,
      };

  /// Transform the result
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
        Success(:final data) => Result.success(transform(data)),
        Error(:final failure) => Result.failure(failure),
      };

  /// Transform with async function
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    return switch (this) {
      Success(:final data) => Result.success(await transform(data)),
      Error(:final failure) => Result.failure(failure),
    };
  }

  /// Handle both cases
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) =>
      switch (this) {
        Success(:final data) => onSuccess(data),
        Error(:final failure) => onFailure(failure),
      };

  /// Get data or throw
  T getOrThrow() => switch (this) {
        Success(:final data) => data,
        Error(:final failure) => throw Exception(failure.message),
      };

  /// Get data or default
  T getOrElse(T defaultValue) => switch (this) {
        Success(:final data) => data,
        Error() => defaultValue,
      };
}

/// Success result
final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Error result
final class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
