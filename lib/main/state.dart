import 'package:batch_api_demo/optional.dart';
import 'package:batch_api_demo/users_repo.dart';
import 'package:collection/collection.dart';

class UserItem {
  final User user;
  final bool isLoading;

  UserItem({
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

class MainState {
  final List<UserItem> users;
  final bool isLoading;
  final Option<Object> error;

  static final initial = MainState(
    users: const <UserItem>[],
    isLoading: true,
    error: Option.none(),
  );

  MainState({
    required this.users,
    required this.isLoading,
    required this.error,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainState &&
          runtimeType == other.runtimeType &&
          const ListEquality<UserItem>().equals(users, other.users) &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode =>
      const ListEquality<UserItem>().hash(users) ^
      isLoading.hashCode ^
      error.hashCode;

  MainState copyWith({
    List<UserItem>? users,
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
