import 'package:mealora/core/errors/failure.dart';

/// Hasil operasi: berhasil dengan nilai, atau gagal dengan [Failure].
sealed class Result<T> {
  const Result();

  /// Hasil berhasil dengan [value].
  const factory Result.ok(T value) = Ok<T>;

  /// Hasil gagal dengan [failure].
  const factory Result.err(Failure failure) = Err<T>;

  bool get isOk => this is Ok<T>;

  bool get isErr => this is Err<T>;

  /// Nilai bila berhasil, `null` bila gagal.
  T? get valueOrNull => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };

  /// Kegagalan bila gagal, `null` bila berhasil.
  Failure? get failureOrNull => switch (this) {
    Ok<T>() => null,
    Err<T>(:final failure) => failure,
  };

  /// Memetakan nilai keberhasilan; kegagalan diteruskan apa adanya.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok<T>(:final value) => Ok<R>(transform(value)),
    Err<T>(:final failure) => Err<R>(failure),
  };
}

/// Hasil berhasil.
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  bool operator ==(Object other) => other is Ok<T> && other.value == value;

  @override
  int get hashCode => Object.hash(Ok<T>, value);

  @override
  String toString() => 'Ok($value)';
}

/// Hasil gagal.
final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;

  @override
  bool operator ==(Object other) => other is Err<T> && other.failure == failure;

  @override
  int get hashCode => Object.hash(Err<T>, failure);

  @override
  String toString() => 'Err($failure)';
}
