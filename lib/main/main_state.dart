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
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode => user.hashCode ^ isLoading.hashCode ^ error.hashCode;
}

@immutable
class MainState {
  final BuiltList<UserItem> users;
  final bool isLoading;
  final Option<UserError> error;
  final bool cancelled;

  static final initial = MainState(
    users: const <UserItem>[].build(),
    isLoading: true,
    error: Option.none(),
    cancelled: false,
  );

  const MainState({
    required this.users,
    required this.isLoading,
    required this.error,
    required this.cancelled,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainState &&
          runtimeType == other.runtimeType &&
          users == other.users &&
          isLoading == other.isLoading &&
          error == other.error &&
          cancelled == other.cancelled;

  @override
  int get hashCode =>
      users.hashCode ^ isLoading.hashCode ^ error.hashCode ^ cancelled.hashCode;

  MainState copyWith({
    BuiltList<UserItem>? users,
    bool? isLoading,
    Option<UserError>? error,
    bool? cancelled,
  }) =>
      MainState(
        users: users ?? this.users,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        cancelled: cancelled ?? this.cancelled,
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
