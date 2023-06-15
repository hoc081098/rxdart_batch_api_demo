import 'package:batch_api_demo/optional.dart';
import 'package:batch_api_demo/users_repo.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

@immutable
class UserItem {
  final User user;
  final bool isLoading;
  final Option<UserError> error;

  const UserItem({
    required this.user,
    required this.isLoading,
    required this.error,
  });

  factory UserItem.loaded(User user) => UserItem(
        user: user,
        isLoading: false,
        error: Option.none(),
      );

  factory UserItem.loading(User user) => UserItem(
        user: user,
        isLoading: true,
        error: Option.none(),
      );

  factory UserItem.failed(User user, UserError error) => UserItem(
        user: user,
        isLoading: false,
        error: error.some(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserItem &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          isLoading == other.isLoading;

  @override
  int get hashCode => user.hashCode ^ isLoading.hashCode;
}

@immutable
class MainState {
  final BuiltList<UserItem> users;
  final bool isLoading;
  final Option<UserError> error;

  static final initial = MainState(
    users: const <UserItem>[].build(),
    isLoading: true,
    error: Option.none(),
  );

  const MainState({
    required this.users,
    required this.isLoading,
    required this.error,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainState &&
          runtimeType == other.runtimeType &&
          users == other.users &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode => users.hashCode ^ isLoading.hashCode ^ error.hashCode;

  MainState copyWith({
    BuiltList<UserItem>? users,
    bool? isLoading,
    Option<UserError>? error,
  }) =>
      MainState(
        users: users ?? this.users,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );
}

extension UserCopyWithNewAvatarUrlExtension on User {
  User copyWithNewAvatarUrl(String? avatarUrl) => User(
        id: id,
        name: name,
        avatarName: avatarName,
        avatarUrl: avatarUrl,
      );
}
