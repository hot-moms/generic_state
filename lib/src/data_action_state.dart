import 'dart:async';

import 'package:meta/meta.dart';

/// {@template data_action_state}
///
/// A summary type for asynchronous state that performs some action with data
/// that can be finished successfully or unsucessfully and notifies about it
/// to listeners.
///
/// Has four variations – `processing`, `idle`, `successfull` and `error`. Every state has a
/// [data] getter that returns the data, and `error` additionally has a [error]
/// getter.
///
/// An example of usage would be a any feature that can signalize to listeners
/// about changes, like authentication and button that reacts to successfull login.
/// {@endtemplate}
sealed class DataActionState<DataEntity extends Object?>
    extends _$DataActionStateBase<DataEntity> {
  static Stream<DataActionState<D>> recreateData<D extends Object?>({
    required Future<D> Function() body,
    bool shouldRethrow = false,
    Duration finishDelay = Duration.zero,
    void Function(Object? error, StackTrace stackTrace)? logError,
  }) async* {
    D? data;
    yield DataActionState.processing(data: null);

    try {
      data = await body();
      yield DataActionState.successful(data: data);
    } on Object catch (e, s) {
      logError?.call(e, s);
      yield DataActionState.error(data: null, error: e);

      if (shouldRethrow) rethrow;
    } finally {
      await Future.delayed(finishDelay);
      yield DataActionState.idle(data: data);
    }
  }

  Stream<DataActionState<DataEntity>> mutateData({
    required Future<DataEntity> Function() body,
    bool shouldRethrow = false,
    Duration finishDelay = Duration.zero,
    void Function(Object? error, StackTrace stackTrace)? logError,
  }) async* {
    yield DataActionState.processing(data: this.data);

    try {
      final data = await body();
      yield DataActionState.successful(data: data);
    } on Object catch (e, s) {
      logError?.call(e, s);
      yield DataActionState.error(data: this.data, error: e);

      if (shouldRethrow) rethrow;
    } finally {
      await Future.delayed(finishDelay);
      yield DataActionState.idle(data: this.data);
    }
  }

  /// {@macro data_action_state}
  const DataActionState({required super.data});

  /// Idling state
  ///
  /// {@macro data_action_state}
  const factory DataActionState.idle({
    required DataEntity? data,
  }) = DataActionState$Idle;

  /// Processing state
  ///
  /// {@macro data_action_state}
  const factory DataActionState.processing({
    required DataEntity? data,
  }) = DataActionState$Processing;

  /// Processing state
  ///
  /// {@macro data_action_state}
  const factory DataActionState.successful({
    required DataEntity? data,
  }) = DataActionState$Successful;

  /// Error state with attached error
  ///
  /// {@macro data_action_state}
  const factory DataActionState.error({
    required DataEntity? data,
    required Object error,
  }) = DataActionState$Error;
}

/// Idling state
///
/// {@nodoc}
final class DataActionState$Idle<DataEntity extends Object?>
    extends DataActionState<DataEntity> {
  /// {@nodoc}
  const DataActionState$Idle({required super.data});
}

/// Processing state
///
/// {@nodoc}
final class DataActionState$Processing<DataEntity extends Object?>
    extends DataActionState<DataEntity> {
  /// {@nodoc}
  const DataActionState$Processing({
    required super.data,
  });
}

/// Successful state
///
/// {@nodoc}
final class DataActionState$Successful<DataEntity extends Object?>
    extends DataActionState<DataEntity> {
  /// {@nodoc}
  const DataActionState$Successful({
    required super.data,
  });
}

/// Error state with attached error
///
/// {@nodoc}
final class DataActionState$Error<DataEntity extends Object?>
    extends DataActionState<DataEntity> {
  final Object error;

  /// {@nodoc}
  const DataActionState$Error({
    required super.data,
    required this.error,
  });

  @override
  int get hashCode => data.hashCode ^ error.hashCode;

  @override
  bool operator ==(covariant DataActionState$Error other) =>
      data == other.data && error == other.error;
}

/// Pattern matching for [DataActionState].
///
typedef DataActionStateMatch<R, S extends DataActionState> = R Function(
  S state,
);

/// {@nodoc}
@immutable
abstract base class _$DataActionStateBase<DataEntity extends Object?> {
  /// {@nodoc}
  const _$DataActionStateBase({required this.data});

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

  /// Pattern matching for [DataActionState].
  R map<R>({
    required DataActionStateMatch<R, DataActionState$Idle> idle,
    required DataActionStateMatch<R, DataActionState$Processing> processing,
    required DataActionStateMatch<R, DataActionState$Successful> successful,
    required DataActionStateMatch<R, DataActionState$Error> error,
  }) =>
      switch (this) {
        final DataActionState$Idle s => idle(s),
        final DataActionState$Processing s => processing(s),
        final DataActionState$Error s => error(s),
        _ => throw AssertionError(),
      };

  /// Pattern matching for [DataActionState].
  R maybeMap<R>({
    DataActionStateMatch<R, DataActionState$Idle>? idle,
    DataActionStateMatch<R, DataActionState$Processing>? processing,
    DataActionStateMatch<R, DataActionState$Successful>? successful,
    DataActionStateMatch<R, DataActionState$Error>? error,
    required R Function() orElse,
  }) =>
      map<R>(
        idle: idle ?? (_) => orElse(),
        processing: processing ?? (_) => orElse(),
        successful: successful ?? (_) => orElse(),
        error: error ?? (_) => orElse(),
      );

  /// Pattern matching for [DataActionState].
  R? mapOrNull<R>({
    DataActionStateMatch<R, DataActionState$Idle>? idle,
    DataActionStateMatch<R, DataActionState$Processing>? processing,
    DataActionStateMatch<R, DataActionState$Successful>? successful,
    DataActionStateMatch<R, DataActionState$Error>? error,
  }) =>
      map<R?>(
        idle: idle ?? (_) => null,
        processing: processing ?? (_) => null,
        successful: successful ?? (_) => null,
        error: error ?? (_) => null,
      );

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other);
}
