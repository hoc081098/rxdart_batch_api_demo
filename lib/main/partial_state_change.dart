import 'package:batch_api_demo/main/main_state.dart';
import 'package:batch_api_demo/optional.dart';
import 'package:batch_api_demo/users_repo.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class MainPartialStateChange {
  MainState reduce(MainState state);
}

// ------------------------------ USERS ------------------------------

class UsersLoadingChange implements MainPartialStateChange {
  @override
  MainState reduce(MainState state) => state.copyWith(
        isLoading: true,
        error: Option.none(),
      );
}

class UsersListChange implements MainPartialStateChange {
  final BuiltList<UserItem> users;

  UsersListChange(this.users);

  @override
  MainState reduce(MainState state) => state.copyWith(
        users: users,
        isLoading: false,
        error: Option.none(),
      );
}

class UsersErrorChange implements MainPartialStateChange {
  final UserError error;

  UsersErrorChange(this.error);

  @override
  MainState reduce(MainState state) => state.copyWith(
        isLoading: false,
        error: Option.some(error),
      );
}

// ------------------------------ USER ITEMS ------------------------------

class UserItemUpdatedChange implements MainPartialStateChange {
  final UserItem userItem;

  UserItemUpdatedChange(this.userItem);

  @override
  MainState reduce(MainState state) {
    return state.copyWith(
      users: state.users
          .map((e) => e.user.id == userItem.user.id ? userItem : e)
          .toBuiltList(),
    );
  }
}
