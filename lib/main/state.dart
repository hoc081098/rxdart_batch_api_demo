import 'package:batch_api_demo/optional.dart';
import 'package:batch_api_demo/users_repo.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

@immutable
class UserItem {
  final User user;
  final bool isLoading;

  const UserItem({
    required this.user,
    required this.isLoading,
  });

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
  final Option<Object> error;

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
    Option<Object>? error,
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
