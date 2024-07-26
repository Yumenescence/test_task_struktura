import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_task_struktura/screens/task_manager_screen.dart';

import 'providers/task_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()..initializeTasks(5)),
      ],
      child: const MaterialApp(
        home: TaskManagerScreen(),
      ),
    );
  }
}
