import 'package:batch_api_demo/main/main_bloc.dart';
import 'package:batch_api_demo/main/main_state.dart';
import 'package:batch_api_demo/optional.dart';
import 'package:batch_api_demo/users_repo.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    context.bloc<MainBloc>().fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch API demo'),
        actions: [
          IconButton(
            onPressed: () => context.bloc<MainBloc>().fetch(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => context.bloc<MainBloc>().cancel(),
            icon: const Icon(Icons.cancel),
          ),
          RxStreamBuilder<bool>(
            stream: UsersRepo.failed$,
            builder: (context, state) => TextButton(
              onPressed: UsersRepo.toggleFailed,
              child: Text(
                state ? 'failed' : 'succeed',
                style: TextStyle(color: state ? Colors.red : Colors.green),
              ),
            ),
          ),
        ],
      ),
      body: SizedBox.expand(
        child: RxStreamBuilder<MainState>(
          stream: context.bloc<MainBloc>().state$,
          builder: (context, state) {
            if (state.cancelled) {
              return const Center(
                child: Text('Cancelled'),
              );
            }

            if (state.error.isNotEmpty) {
              return Center(
                child: Text('Error: ${state.error.valueOrNull()!.message}'),
              );
            }

            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return UsersListView(items: state.users);
          },
        ),
      ),
    );
  }
}

class UsersListView extends StatelessWidget {
  final BuiltList<UserItem> items;

  const UsersListView({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return UserItemRow(
          key: ValueKey(item.user.id),
          item: item,
        );
      },
    );
  }
}

class UserItemRow extends StatelessWidget {
  final UserItem item;

  const UserItemRow({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.user.name),
      subtitle: switch ((item.isLoading, item.error)) {
        (true, _) => Text(
            'Loading...',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Colors.red),
          ),
        (_, Some(value: final error)) => Text('Error: ${error.message}'),
        _ => item.user.avatarUrl != null
            ? Text('Avatar: ${item.user.avatarUrl}')
            : const Text('No avatar'),
      },
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
    );
  }
}
