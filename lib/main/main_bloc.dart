import 'dart:async';

import 'package:batch_api_demo/main/main_state.dart';
import 'package:batch_api_demo/main/partial_state_change.dart';
import 'package:batch_api_demo/users_repo.dart';
import 'package:built_collection/built_collection.dart';
import 'package:disposebag/disposebag.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

const batchSize = 4;
const maxRetries = 3;

class MainBloc extends DisposeCallbackBaseBloc {
  final Func0<void> fetch;

  final StateStream<MainState> state$;

  MainBloc._({
    required Func0<void> dispose,
    required this.fetch,
    required this.state$,
  }) : super(dispose);

  factory MainBloc({
    required UsersRepo usersRepo,
  }) {
    final fetchS = StreamController<void>();

    final state$ = fetchS.stream
        .switchMap((_) => _fetchUsersAndAvatars(usersRepo))
        .scan((state, change, _) => change.reduce(state), MainState.initial)
        .publishState(MainState.initial);

    return MainBloc._(
      dispose: DisposeBag([fetchS, state$.connect()]).dispose,
      fetch: fetchS.addNull,
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
                        (e) => _fetchAvatars(usersRepo, e.user), batchSize)
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
    Single.retry(
      () => usersRepo.fetchUserAvatarUrl(user),
      maxRetries,
    )
        .map(
          (either) => either.fold(
            ifLeft: (e) => UserItem.failed(user, e),
            ifRight: (avatarUrl) =>
                UserItem.loaded(user.copyWithNewAvatarUrl(avatarUrl)),
          ),
        )
        .map(UserItemUpdatedChange.new);
