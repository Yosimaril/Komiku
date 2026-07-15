import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komiku/models/api.dart';
import 'package:komiku/provider/index_nav_provider.dart';
import 'package:komiku/provider/theme_state_provider.dart';
import 'package:komiku/screens/auth/login_screen.dart';
import 'package:komiku/screens/auth/register_screen.dart';
import 'package:komiku/screens/category/list_category_screen.dart';
import 'package:komiku/screens/comic/comic_detail_screen.dart';
import 'package:komiku/screens/comic/list_comic_screen.dart';
import 'package:komiku/screens/home_screen.dart';
import 'package:komiku/screens/setting_screen.dart';
import 'package:komiku/services/api_service.dart';
import 'package:komiku/services/secure_storage_service.dart';
import 'package:komiku/services/shared_preferences_service.dart';
import 'package:komiku/static/app_config.dart';
import 'package:komiku/static/app_theme_mode.dart';
import 'package:komiku/static/navigation_route.dart';
import 'package:komiku/style/komiku_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final secureStorage = SecureStorageService(const FlutterSecureStorage());

  ApiService.initialize(Api(secureStorage));

  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (context) => SharedPreferencesService(sharedPreferences),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) =>
              ThemeStateProvider(context.read<SharedPreferencesService>()),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => IndexNavProvider(),
        ),
      ],
      child: const SafeArea(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.name.value,
      themeMode:
          context.watch<ThemeStateProvider>().themeMode == AppThemeMode.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      theme: KomikuTheme.lightTheme,
      darkTheme: KomikuTheme.darkTheme,
      initialRoute: NavigationRoute.homeScreen.name,
      routes: {
        NavigationRoute.homeScreen.name: (context) => const HomeScreen(),
        NavigationRoute.loginScreen.name: (context) => const LoginScreen(),
        NavigationRoute.registerScreen.name: (context) =>
            const RegisterScreen(),
        NavigationRoute.listComicScreen.name: (context) => ListComicScreen(
          categoryId: ModalRoute.of(context)?.settings.arguments as int?,
        ),
        NavigationRoute.listCategoryScreen.name: (context) =>
            const ListCategoryScreen(),
        NavigationRoute.comicDetailScreen.name: (context) => ComicDetailScreen(
          comicId: ModalRoute.of(context)?.settings.arguments as int,
        ),
        NavigationRoute.settingScreen.name: (context) => const SettingScreen(),
      },
    );
  }
}
