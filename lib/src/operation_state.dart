import 'dart:async';

import 'package:meta/meta.dart';

/// {@template operation_state}
///
/// A summary type for asynchronous operation that's contains data obtained as a result of an
/// this operation.
///
/// Has four variations – `initial`, `processing`, `success` and `error`.
/// `success` stores [data], while `error` stores [error] and `initial` and
/// `processing` are empty.
///
/// An example of usage would be a result of an HTTP request through its
/// stages.
/// {@endtemplate}
sealed class OperationState<DataEntity extends Object?>
    extends _$OperationStateBase<DataEntity> {
  static Stream<OperationState<D>> mutateFromFuture<D extends Object?>({
    required Future<D> Function() body,
    bool shouldRethrow = false,
    void Function(Object? error, StackTrace stackTrace)? logError,
  }) async* {
    yield OperationState.processing();

    try {
      final data = await body();

      yield OperationState.successful(data: data);
    } on Object catch (e, s) {
      logError?.call(e, s);
      yield OperationState.error(error: e);

      if (shouldRethrow) rethrow;
    }
  }

  /// {@macro operation_state}
  const OperationState({super.data});

  /// Idling state
  ///
  /// {@macro operation_state}
  const factory OperationState.initial() = OperationState$Initial;

  /// Processing state
  ///
  /// {@macro operation_state}
  const factory OperationState.processing() = OperationState$Processing;

  /// Successful state
  ///
  /// {@macro operation_state}
  const factory OperationState.successful({
    required DataEntity? data,
  }) = OperationState$Successful;

  /// Error state with attached error
  ///
  /// {@macro operation_state}
  const factory OperationState.error({
    required Object error,
  }) = OperationState$Error;
}

/// Idling state
///
/// {@nodoc}
final class OperationState$Initial<DataEntity extends Object?>
    extends OperationState<DataEntity> {
  /// {@nodoc}
  const OperationState$Initial();
}

/// Processing state
///
/// {@nodoc}
final class OperationState$Processing<DataEntity extends Object?>
    extends OperationState<DataEntity> {
  /// {@nodoc}
  const OperationState$Processing();
}

/// Successful state
///
/// {@nodoc}
final class OperationState$Successful<DataEntity extends Object?>
    extends OperationState<DataEntity> {
  /// {@nodoc}
  const OperationState$Successful({
    super.data,
  });
}

/// Error state with attached error
///
/// {@nodoc}
final class OperationState$Error<DataEntity extends Object?>
    extends OperationState<DataEntity> {
  final Object error;

  /// {@nodoc}
  const OperationState$Error({
    required this.error,
  });

  @override
  int get hashCode => data.hashCode ^ error.hashCode;

  @override
  bool operator ==(covariant OperationState$Error other) =>
      data == other.data && error == other.error;
}

/// Pattern matching for [OperationState].
///
typedef OperationStateMatch<R, S extends OperationState> = R Function(
  S state,
);

/// {@nodoc}
@immutable
abstract base class _$OperationStateBase<DataEntity extends Object?> {
  /// {@nodoc}
  const _$OperationStateBase({required this.data});

  /// Data entity payload.
  ///
  @nonVirtual
  final DataEntity? data;

  /// Has data?
  bool get hasData => data != null;

  /// If an error has occurred?
  bool get hasError => maybeMap<bool>(orElse: () => false, error: (_) => true);

  /// Is in progress state?
  bool get isProcessing =>
      maybeMap<bool>(orElse: () => false, processing: (_) => true);

  /// Is in initial state?
  bool get isSuccessful =>
      maybeMap<bool>(orElse: () => false, successful: (_) => true);

  /// Pattern matching for [OperationState].
  R map<R>({
    required OperationStateMatch<R, OperationState$Initial> initial,
    required OperationStateMatch<R, OperationState$Processing> processing,
    required OperationStateMatch<R, OperationState$Successful> successful,
    required OperationStateMatch<R, OperationState$Error> error,
  }) =>
      switch (this) {
        final OperationState$Initial s => initial(s),
        final OperationState$Processing s => processing(s),
        final OperationState$Successful s => successful(s),
        final OperationState$Error s => error(s),
        _ => throw AssertionError(),
      };

  /// Pattern matching for [OperationState].
  R maybeMap<R>({
    OperationStateMatch<R, OperationState$Initial>? initial,
    OperationStateMatch<R, OperationState$Processing>? processing,
    OperationStateMatch<R, OperationState$Successful>? successful,
    OperationStateMatch<R, OperationState$Error>? error,
    required R Function() orElse,
  }) =>
      map<R>(
        initial: initial ?? (_) => orElse(),
        processing: processing ?? (_) => orElse(),
        successful: successful ?? (_) => orElse(),
        error: error ?? (_) => orElse(),
      );

  /// Pattern matching for [OperationState].
  R? mapOrNull<R>({
    OperationStateMatch<R, OperationState$Initial>? initial,
    OperationStateMatch<R, OperationState$Processing>? processing,
    OperationStateMatch<R, OperationState$Successful>? successful,
    OperationStateMatch<R, OperationState$Error>? error,
  }) =>
      map<R?>(
        initial: initial ?? (_) => null,
        processing: processing ?? (_) => null,
        successful: successful ?? (_) => null,
        error: error ?? (_) => null,
      );

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other);
}
