import 'package:batch_api_demo/main/state.dart';
import 'package:batch_api_demo/optional.dart';

abstract class PartialStateChange {
  MainState reduce(MainState state);
}

// ------------------------------ USERS ------------------------------

class UsersLoadingChange implements PartialStateChange {
  @override
  MainState reduce(MainState state) => state.copyWith(
        isLoading: true,
        error: Option.none(),
      );
}

class UsersListChange implements PartialStateChange {
  final List<UserItem> users;

  UsersListChange(this.users);

  @override
  MainState reduce(MainState state) => state.copyWith(
        users: users,
        isLoading: false,
        error: Option.none(),
      );
}

class UsersErrorChange implements PartialStateChange {
  final Object error;

  UsersErrorChange(this.error);

  @override
  MainState reduce(MainState state) => state.copyWith(
        isLoading: false,
        error: Option.some(error),
      );
}

// ------------------------------ USER ITEMS ------------------------------

class UserItemUpdatedChange implements PartialStateChange {
  final UserItem userItem;

  UserItemUpdatedChange(this.userItem);

  @override
  MainState reduce(MainState state) => state.copyWith(
        users: state.users
            .map((e) => e.user.id == userItem.user.id ? userItem : e)
            .toList(),
      );
}
