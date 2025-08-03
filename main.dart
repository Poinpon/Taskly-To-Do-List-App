import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list_app/models/task_model.dart';
import 'package:to_do_list_app/models/user_model.dart';
import 'Pages/home_page.dart';
import 'Pages/login_page.dart';

void main() async {
  await Hive.initFlutter();

  //await Hive.deleteFromDisk();

  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(UserModelAdapter());

  await Hive.openBox<TaskModel>('mybox');
  await Hive.openBox<UserModel>('users');
  await Hive.openBox('session');
  await Hive.openBox('categoryBox');
  await Hive.openBox('todoBox');

  final sessionBox = Hive.box('session');
  final isLoggedIn = sessionBox.get('loggedInUser') != null;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}
