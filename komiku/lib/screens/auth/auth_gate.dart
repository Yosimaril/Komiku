import 'package:flutter/material.dart';
import 'package:komiku/screens/auth/login_screen.dart';
import 'package:komiku/screens/home_screen.dart';
import 'package:komiku/services/secure_storage_service.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<bool> _tokenFuture;

  @override
  void initState() {
    super.initState();
    _tokenFuture = _hasToken();
  }

  Future<bool> _hasToken() async {
    final secureStorage = context.read<SecureStorageService>();
    final token = await secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _tokenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
