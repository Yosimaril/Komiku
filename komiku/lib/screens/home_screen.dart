import 'package:flutter/material.dart';
import 'package:komiku/components/home_screen/app_drawer.dart';
import 'package:komiku/provider/index_nav_provider.dart';
import 'package:komiku/screens/category/list_category_screen.dart';
import 'package:komiku/screens/comic/list_comic_screen.dart';
import 'package:komiku/screens/setting_screen.dart';
import 'package:komiku/static/navigation_route.dart';
import 'package:komiku/style/komiku_colors.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Key _comicListKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<IndexNavProvider>();
    final title = switch (navProvider.indexBottomNavBar) {
      0 => "Comics",
      1 => "Categories",
      _ => "Settings",
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: const AppDrawer(),
      body: switch (navProvider.indexBottomNavBar) {
        0 => ListComicScreen(key: _comicListKey),
        1 => const ListCategoryScreen(),
        _ => const SettingScreen(),
      },
      floatingActionButton: navProvider.indexBottomNavBar == 0
          ? FloatingActionButton(
              backgroundColor: KomikuColors.blue.color,
              foregroundColor: KomikuColors.white.color,
              onPressed: () async {
                final refresh = await Navigator.pushNamed(
                  context,
                  NavigationRoute.createComicScreen.name,
                );
                if (refresh == true) {
                  setState(() {
                    _comicListKey = UniqueKey();
                  });
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navProvider.indexBottomNavBar,
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
