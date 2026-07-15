import 'package:flutter/material.dart';
import 'package:komiku/provider/index_nav_provider.dart';
import 'package:komiku/screens/category/list_category_screen.dart';
import 'package:komiku/screens/comic/list_comic_screen.dart';
import 'package:komiku/screens/setting_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<IndexNavProvider>(
        builder: (context, value, child) {
          return switch (value.indexBottomNavBar) {
            0 => const ListComicScreen(),
            1 => const ListCategoryScreen(),
            _ => const SettingScreen(),
          };
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: context.watch<IndexNavProvider>().indexBottomNavBar,
        onTap: (index) {
          context.read<IndexNavProvider>().setIndexBottomNavBar = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Comics",
            tooltip: "Comics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: "Categories",
            tooltip: "Categories",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
            tooltip: "Settings",
          ),
        ],
      ),
    );
  }
}
