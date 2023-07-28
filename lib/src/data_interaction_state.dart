import 'dart:async';

import 'package:meta/meta.dart';

/// {@template data_persistent_state}
///
/// A summary type for asynchronous state that interacts with inner data and
/// modifies it.
///
/// Has three variations – `processing`, `idle` and `error`. Every state has a
/// [data] getter that returns the data, and `error` additionally has a [error]
/// getter.
///
/// An example of usage would be a state of apps settings – they are present
/// from the start and throughout the app and can be loaded, idle or error.
/// {@endtemplate}
sealed class DataInteractionState<DataEntity extends Object?>
    extends _$DataInteractionStateBase<DataEntity> {
  static Stream<DataInteractionState<D>> reCreate<D extends Object?>({
    required Future<D> Function() body,
    bool shouldRethrow = false,
    void Function(Object? error, StackTrace stackTrace)? logError,
  }) async* {
    yield DataInteractionState.processing(data: null);

    try {
      final data = await body();
      yield DataInteractionState.idle(data: data);
    } on Object catch (e, s) {
      logError?.call(e, s);
      yield DataInteractionState.error(data: null, error: e);

      if (shouldRethrow) rethrow;
    }
  }

  Stream<DataInteractionState> mutateFromFuture({
    required Future<DataEntity> Function() body,
    bool shouldRethrow = false,
    void Function(Object? error, StackTrace stackTrace)? logError,
  }) async* {
    yield DataInteractionState.processing(data: this.data);

    try {
      final data = await body();
      yield DataInteractionState.idle(data: data);
    } on Object catch (e, s) {
      logError?.call(e, s);
      yield DataInteractionState.error(data: this.data, error: e);

      if (shouldRethrow) rethrow;
    }
  }

  /// {@macro data_persistent_state}
  const DataInteractionState({required super.data});

  /// Idling state
  ///
  /// {@macro data_persistent_state}
  const factory DataInteractionState.idle({
    required DataEntity? data,
  }) = DataInteractionState$Idle;

  /// Processing state
  ///
  /// {@macro data_persistent_state}
  const factory DataInteractionState.processing({
    required DataEntity? data,
  }) = DataInteractionState$Processing;

  /// Error state with attached error
  ///
  /// {@macro data_persistent_state}
  const factory DataInteractionState.error({
    required DataEntity? data,
    required Object error,
  }) = DataInteractionState$Error;
}

/// Idling state
///
/// {@nodoc}
final class DataInteractionState$Idle<DataEntity extends Object?>
    extends DataInteractionState<DataEntity> {
  /// {@nodoc}
  const DataInteractionState$Idle({required super.data});
}

/// Processing state
///
/// {@nodoc}
final class DataInteractionState$Processing<DataEntity extends Object?>
    extends DataInteractionState<DataEntity> {
  /// {@nodoc}
  const DataInteractionState$Processing({
    required super.data,
  });
}

/// Error state with attached error
///
/// {@nodoc}
final class DataInteractionState$Error<DataEntity extends Object?>
    extends DataInteractionState<DataEntity> {
  final Object error;

  /// {@nodoc}
  const DataInteractionState$Error({
    required super.data,
    required this.error,
  });

  @override
  int get hashCode => data.hashCode ^ error.hashCode;

  @override
  bool operator ==(covariant DataInteractionState$Error other) =>
      data == other.data && error == other.error;
}

/// Pattern matching for [DataInteractionState].
///
typedef DataInteractionStateMatch<R, S extends DataInteractionState> = R
    Function(
  S state,
);

/// {@nodoc}
@immutable
abstract base class _$DataInteractionStateBase<DataEntity extends Object?> {
  /// {@nodoc}
  const _$DataInteractionStateBase({required this.data});

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

  /// Is in idle state?
  bool get isIdling => !isProcessing;

  /// Pattern matching for [DataInteractionState].
  R map<R>({
    required DataInteractionStateMatch<R, DataInteractionState$Idle> idle,
    required DataInteractionStateMatch<R, DataInteractionState$Processing>
        processing,
    required DataInteractionStateMatch<R, DataInteractionState$Error> error,
  }) =>
      switch (this) {
        final DataInteractionState$Idle s => idle(s),
        final DataInteractionState$Processing s => processing(s),
        final DataInteractionState$Error s => error(s),
        _ => throw AssertionError(),
      };

  /// Pattern matching for [DataInteractionState].
  R maybeMap<R>({
    DataInteractionStateMatch<R, DataInteractionState$Idle>? idle,
    DataInteractionStateMatch<R, DataInteractionState$Processing>? processing,
    DataInteractionStateMatch<R, DataInteractionState$Error>? error,
    required R Function() orElse,
  }) =>
      map<R>(
        idle: idle ?? (_) => orElse(),
        processing: processing ?? (_) => orElse(),
        error: error ?? (_) => orElse(),
      );

  /// Pattern matching for [DataInteractionState].
  R? mapOrNull<R>({
    DataInteractionStateMatch<R, DataInteractionState$Idle>? idle,
    DataInteractionStateMatch<R, DataInteractionState$Processing>? processing,
    DataInteractionStateMatch<R, DataInteractionState$Error>? error,
  }) =>
      map<R?>(
        idle: idle ?? (_) => null,
        processing: processing ?? (_) => null,
        error: error ?? (_) => null,
      );

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other);
}
