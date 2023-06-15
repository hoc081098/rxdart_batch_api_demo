import 'dart:async';

import 'package:batch_api_demo/main/main_state.dart';
import 'package:batch_api_demo/main/partial_state_change.dart';
import 'package:batch_api_demo/users_repo.dart';
import 'package:batch_api_demo/utils.dart';
import 'package:built_collection/built_collection.dart';
import 'package:disposebag/disposebag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

const _batchSize = 4;
const _maxRetries = 3;

class MainBloc extends DisposeCallbackBaseBloc {
  final Func0<void> fetch;
  final Func0<void> cancel;

  final StateStream<MainState> state$;

  MainBloc._({
    required Func0<void> dispose,
    required this.fetch,
    required this.cancel,
    required this.state$,
  }) : super(dispose);

  factory MainBloc({
    required UsersRepo usersRepo,
  }) {
    final fetchS = StreamController<void>();
    final cancelS = PublishSubject<void>(sync: true);

    final state$ = Rx.merge([
      fetchS.stream.switchMap(
        (_) => _fetchUsersAndAvatars(usersRepo)
            .doOnCancel(
                () => debugPrint('MainBloc._fetchUsersAndAvatars() cancelled!'))
            .takeUntil(cancelS.stream),
      ),
      cancelS.stream.asyncMap((event) => Future.value(UsersCancelledChange())),
    ])
        .scan((state, change, _) => change.reduce(state), MainState.initial)
        .publishState(MainState.initial);

    return MainBloc._(
      dispose: DisposeBag([
        fetchS,
        cancelS,
        state$.connect(),
      ]).dispose,
      fetch: fetchS.addNull,
      cancel: cancelS.addNull,
      state$: state$,
    );
  }
}

Stream<MainPartialStateChange> _fetchUsersAndAvatars(UsersRepo usersRepo) =>
    usersRepo
        .fetchUsers()
        .exhaustMap(
          (either) => either.fold(
            ifLeft: (e) => Stream.value(UsersErrorChange(e)),
            ifRight: (users) {
              final items = users.map(UserItem.loading).toBuiltList();

              return Rx.concat<MainPartialStateChange>([
                Stream.value(UsersListChange(items)),
                Stream.fromIterable(items)
                    .flatMapBatches(
                        (e) => _fetchAvatars(usersRepo, e.user), _batchSize)
                    .expand(identity),
              ]);
            },
          ),
        )
        .startWith(UsersLoadingChange());

Stream<MainPartialStateChange> _fetchAvatars(
  UsersRepo usersRepo,
  User user,
) =>
    retryEitherSingle<UserError, String>(
      () => usersRepo.fetchUserAvatarUrl(user),
      _maxRetries,
    )
        .map(
          (either) => either.fold(
            ifLeft: (e) => UserItem.failed(user, e),
            ifRight: (avatarUrl) =>
                UserItem.loaded(user.copyWithNewAvatarUrl(avatarUrl)),
          ),
        )
        .map(UserItemUpdatedChange.new);
