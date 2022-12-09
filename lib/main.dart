import 'package:batch_api_demo/main/bloc.dart';
import 'package:batch_api_demo/main/home_page.dart';
import 'package:batch_api_demo/users_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_pattern/flutter_bloc_pattern.dart';
import 'package:flutter_provider/flutter_provider.dart';

void main() {
  runApp(
    Provider.factory(
      (context) => UsersRepo(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.purple,
      ),
      home: BlocProvider(
        initBloc: (context) => MainBloc(usersRepo: context.get()),
        child: const MyHomePage(),
      ),
    );
  }
}
