import 'package:flutter/cupertino.dart';
import 'package:rxdart_ext/rxdart_ext.dart';

class User {
  final int id;
  final String name;
  final String avatarName;
  final String? avatarUrl;

  User({
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

class UsersRepo {
  Single<List<User>> fetchUsers() => Single.fromCallable(() async {
        await delay(2000);
        return List.generate(
          20,
          (index) => User(
            id: index + 1,
            name: 'Name $index',
            avatarName: 'avatar_$index',
            avatarUrl: null,
          ),
        );
      }).doOnListen(() => debugPrint('UsersRepo.fetchUsers() started'));

  Single<String> fetchUserAvatarUrl(User user) => Single.fromCallable(() async {
        await delay(2000);
        return 'avatar_${user.id}.jpg';
      }).doOnListen(
          () => debugPrint('UsersRepo.fetchUserAvatarUrl(${user.id}) started'));
}
