import 'package:flutter/material.dart';
import 'package:luna_app/repositories/auth_repository.dart';
import 'package:luna_app/screens/home_screen.dart';
import 'package:luna_app/screens/login_screen.dart';
import 'package:luna_app/screens/profile_screen.dart';
import 'package:luna_app/screens/register_screen.dart';
// lib/main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authRepo = AuthRepository();
  // Перевіряємо, чи є залогінений користувач
  final currentUser = await authRepo.getCurrentUser();

  runApp(MyApp(isLoggedIn: currentUser != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Luna IoT',
      // Якщо залогінений — йдемо на Home, якщо ні — на Login
      initialRoute: isLoggedIn ? '/home' : '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
