import 'dart:async';

import 'package:batch_api_demo/main/partial_state_change.dart';
import 'package:batch_api_demo/main/state.dart';
import 'package:batch_api_demo/users_repo.dart';
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
        .switchMap((_) => fetchUsersAndAvatars(usersRepo))
        .scan((state, change, _) => change.reduce(state), MainState.initial)
        .publishState(MainState.initial);

    return MainBloc._(
      dispose: DisposeBag([fetchS, state$.connect()]).dispose,
      fetch: () => fetchS.add(null),
      state$: state$,
    );
  }

  static Stream<PartialStateChange> fetchUsersAndAvatars(UsersRepo usersRepo) =>
      usersRepo
          .fetchUsers()
          .exhaustMap((users) {
            final items = users
                .map((user) => UserItem(user: user, isLoading: true))
                .toList(growable: false);

            return Rx.concat<PartialStateChange>([
              Stream.value(UsersListChange(items)),
              Stream.fromIterable(items)
                  .flatMapBatches((e) => fetchAvatars(usersRepo, e), batchSize)
                  .expand(identity),
            ]);
          })
          .startWith(UsersLoadingChange())
          .onErrorReturnWith((e, s) => UsersErrorChange(e));

  static Stream<PartialStateChange> fetchAvatars(
    UsersRepo usersRepo,
    UserItem item,
  ) =>
      Single.retry(
        () => usersRepo.fetchUserAvatarUrl(item.user),
        maxRetries,
      )
          .map(
            (avatarUrl) => UserItem(
              user: item.user.copyWithNewAvatarUrl(avatarUrl),
              isLoading: false,
            ),
          )
          .onErrorReturnWith(
              (e, s) => UserItem(user: item.user, isLoading: false))
          .map(UserItemUpdatedChange.new);
}
