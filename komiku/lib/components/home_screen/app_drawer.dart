import 'package:flutter/material.dart';
import 'package:komiku/services/secure_storage_service.dart';
import 'package:komiku/static/navigation_route.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("Komiku User"),
            accountEmail: Text("komiku@example.com"),
            currentAccountPicture: CircleAvatar(
              child: Text(
                "Temporary",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.category),
            title: Text('Categories'),
            onTap: () {
              Navigator.pushNamed(context, '/categories');
            },
          ),
          ListTile(
              leading: Icon(Icons.book),
              title: Text('Comics'),
              onTap: () {
                Navigator.pushNamed(context, '/comics');
              }
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.add_circle_outline),
            title: Text('Create Comic'),
            onTap: () {
              Navigator.pushNamed(context, '/create-comic');
            },
          ),
          Divider(),
          SwitchListTile(
            secondary: Icon(Icons.dark_mode),
            title: Text('Dark Mode'),
            value: true,
            onChanged: (value) {},
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
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
