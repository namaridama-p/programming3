import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './apis/navigation_state.dart';
import 'components/schedule_state.dart'; // インポートパスを確認
import 'widget/my_home_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NavigationState()),
        ChangeNotifierProvider(create: (context) => ScheduleState()), // ここ！
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Provider Bottom Navigation (分割)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}