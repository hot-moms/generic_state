# Generic States

A tiny package that contains predefined states that can be used with any state management solution independently (mostly stream-based, because contains predefined Stream-returnable states mutators)

#### `DataEntity` represents any Object that can be contained by state itself

### Data Action State

A summary type for asynchronous state that performs some action with data
that can be finished successfully or unsucessfully and notifies about it
to listeners.

Has four variations – `processing`, `idle`, `successfull` and `error`. Every state has a
[data] getter that returns the data, and `error` additionally has a [error]
getter.

An example of usage would be a any feature that can signalize to listeners
about changes, like authentication and button that reacts to successfull login.
```
  const factory DataActionState.idle({
    required DataEntity? data,
  }) = DataActionState$Idle;

  const factory DataActionState.processing({
    required DataEntity? data,
  }) = DataActionState$Processing;

  const factory DataActionState.successful({
    required DataEntity? data,
  }) = DataActionState$Successful;

  const factory DataActionState.error({
    required DataEntity? data,
    required Object error,
  }) = DataActionState$Error;
}
```

### Data Interaction State

A summary type for asynchronous state that interacts with inner data and
modifies it.

Has three variations – `processing`, `idle` and `error`. Every state has a
[data] getter that returns the data, and `error` additionally has a [error]
getter.

An example of usage would be a state of apps settings – they are present
from the start and throughout the app and can be loaded, idle or error.

```
 const factory DataInteractionState.idle({
    required DataEntity? data,
  }) = DataInteractionState$Idle;

  const factory DataInteractionState.processing({
    required DataEntity? data,
  }) = DataInteractionState$Processing;

  const factory DataInteractionState.error({
    required DataEntity? data,
    required Object error,
  }) = DataInteractionState$Error;
```

### Operation State

A summary type for asynchronous operation that's contains data obtained as a result of an
this operation.

Has four variations – `initial`, `processing`, `success` and `error`.
`success` stores [data], while `error` stores [error] and `initial` and
`processing` are empty.

An example of usage would be a result of an HTTP request through its
stages.
```
const factory OperationState.initial() = OperationState$Initial;

const factory OperationState.processing() = OperationState$Processing;

const factory OperationState.successful({
required DataEntity? data,
}) = OperationState$Successful;

const factory OperationState.error({
required Object error,
}) = OperationState$Error;
```

---
inspired by https://github.com/purplenoodlesoop/sum

2023, Archie Kitsushimo
