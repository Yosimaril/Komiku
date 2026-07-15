import 'package:flutter/material.dart';
import 'package:komiku/style/komiku_theme.dart';

import 'screens/home_shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();

  static MyAppState of(BuildContext context) {
    return context.findAncestorStateOfType<MyAppState>()!;
  }
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Komiku',
      themeMode: _themeMode,
      theme: KomikuTheme.lightTheme,
      darkTheme: KomikuTheme.darkTheme,
      home: const HomeShell(),
    )
  }
}

