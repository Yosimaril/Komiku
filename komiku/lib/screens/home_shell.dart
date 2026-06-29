import 'package:flutter/material.dart';

import 'category_screen.dart';
import 'search_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CategoryScreen(),
    SearchScreen(),
  ];

  final List<String> _titles = const [
    'Categories',
    'Search',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        fixedColor: Colors.teal,
        items: const [
          BottomNavigationBarItem(label: 'Categories', icon: Icon(Icons.category)),
          BottomNavigationBarItem(label: 'Search', icon: Icon(Icons.search)),
        ],
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

