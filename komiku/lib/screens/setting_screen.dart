import 'package:flutter/material.dart';
import 'package:komiku/provider/theme_state_provider.dart';
import 'package:komiku/static/app_theme_mode.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Preferences",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Consumer<ThemeStateProvider>(
                  builder: (context, value, child) => SwitchListTile(
                    title: Text(
                      "Dark Mode",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    value: value.themeMode == AppThemeMode.dark,
                    onChanged: (value) {
                      if (value) {
                        context.read<ThemeStateProvider>().setThemeMode(
                          AppThemeMode.dark,
                        );
                      } else {
                        context.read<ThemeStateProvider>().setThemeMode(
                          AppThemeMode.light,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
