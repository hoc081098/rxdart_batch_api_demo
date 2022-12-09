import 'package:batch_api_demo/main/bloc.dart';
import 'package:batch_api_demo/main/state.dart';
import 'package:batch_api_demo/optional.dart';
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
      ),
      body: SizedBox.expand(
        child: RxStreamBuilder<MainState>(
          stream: context.bloc<MainBloc>().state$,
          builder: (context, state) {
            if (state.error.isNotEmpty) {
              return Center(
                child: Text('Error: ${state.error.valueOrNull()}'),
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
  final List<UserItem> items;

  const UsersListView({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return UserItemRow(item: item);
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
      subtitle: item.isLoading
          ? Text(
              'Loading...',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.red),
            )
          : item.user.avatarUrl != null
              ? Text('Avatar: ${item.user.avatarUrl}')
              : const Text('No avatar'),
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
    );
  }
}
