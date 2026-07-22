import 'package:flutter/material.dart';
import 'package:komiku/provider/index_nav_provider.dart';
import 'package:komiku/services/secure_storage_service.dart';
import 'package:komiku/static/navigation_route.dart';
import 'package:provider/provider.dart';
import 'package:komiku/provider/theme_state_provider.dart';
import 'package:komiku/static/app_theme_mode.dart';
import 'dart:convert';
import 'package:komiku/models/user.dart';

class _AppDrawerState extends State<AppDrawer> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final secureStorage = context.read<SecureStorageService>();
    final userJson = await secureStorage.getUser();
    if (userJson != null) {
      setState(() {
        _currentUser = User.fromJson(jsonDecode(userJson));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_currentUser?.username ?? "Komiku User"),
            accountEmail: const Text("Komiku Reader"),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: NetworkImage(
                'https://i.pinimg.com/236x/b3/63/1f/b3631f46018f8ddafae3e07b0bf9ea42.jpg',
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Comics'),
            onTap: () {
              context.read<IndexNavProvider>().setIndexBottomNavBar = 0;
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            onTap: () {
              context.read<IndexNavProvider>().setIndexBottomNavBar = 1;
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              context.read<IndexNavProvider>().setIndexBottomNavBar = 2;
              Navigator.pop(context);
            },
          ),
          Divider(),
          Consumer<ThemeStateProvider>(
            builder: (context, value, child) => SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              value: value.themeMode == AppThemeMode.dark,
              onChanged: (isDark) {
                context.read<ThemeStateProvider>().setThemeMode(
                  isDark ? AppThemeMode.dark : AppThemeMode.light,
                );
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            textColor: Colors.red,
            onTap: () async {
              final secureStorage = context.read<SecureStorageService>();
              await secureStorage.deleteToken();

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  NavigationRoute.loginScreen.name,
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}
