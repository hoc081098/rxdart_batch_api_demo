import 'package:built_collection/built_collection.dart';
import 'package:dart_either/dart_either.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

@immutable
class User {
  final int id;
  final String name;
  final String avatarName;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.name,
    required this.avatarName,
    this.avatarUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          avatarName == other.avatarName &&
          avatarUrl == other.avatarUrl;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ avatarName.hashCode ^ avatarUrl.hashCode;

  @override
  String toString() =>
      'User{id: $id, name: $name, avatarName: $avatarName, avatarUrl: $avatarUrl}';
}

@immutable
class UserError {
  final ErrorAndStackTrace errorAndStackTrace;
  final String message;

  const UserError(this.errorAndStackTrace, this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserError &&
          runtimeType == other.runtimeType &&
          errorAndStackTrace == other.errorAndStackTrace &&
          message == other.message;

  @override
  int get hashCode => errorAndStackTrace.hashCode ^ message.hashCode;
}

class UsersRepo {
  static final _failedS = StateSubject(false);

  static bool get _failed => _failedS.value;

  static BuiltList<User> _genFakeUsers([void _]) => _failed
      ? throw Exception()
      : List.generate(
          20,
          (index) => User(
            id: index + 1,
            name: 'Name $index',
            avatarName: 'avatar_$index',
            avatarUrl: null,
          ),
        ).build();

  static String Function([void _]) _genFakeUserAvatarUrl(User user) =>
      ([_]) => _failed ? throw Exception() : 'https://avatar_${user.id}.jpg';

  // ---------------------------- PUBLIC ----------------------------

  static void toggleFailed() => _failedS.update((v) => !v);

  static StateStream<bool> get failed$ => _failedS.stream;

  Single<Either<UserError, BuiltList<User>>> fetchUsers() =>
      Single.timer(null, const Duration(seconds: 2))
          .map(_genFakeUsers)
          .doOnListen(() => debugPrint('UsersRepo.fetchUsers() started'))
          .toEitherSingle(
            (e, s) => UserError(
              ErrorAndStackTrace(e, s),
              'Failed to fetch users',
            ),
          );

  Single<Either<UserError, String>> fetchUserAvatarUrl(User user) =>
      Single.timer(null, const Duration(seconds: 2))
          .map(_genFakeUserAvatarUrl(user))
          .doOnListen(() =>
              debugPrint('UsersRepo.fetchUserAvatarUrl(${user.id}) started'))
          .toEitherSingle(
            (e, s) => UserError(
              ErrorAndStackTrace(e, s),
              'Failed to fetch avatar url for user ${user.id}',
            ),
          );
}
