import 'package:flutter/material.dart';
import 'package:luna_app/screens/home_screen.dart';
import 'package:luna_app/screens/login_screen.dart';
import 'package:luna_app/screens/profile_screen.dart';
import 'package:luna_app/screens/register_screen.dart';

void main() => runApp(const LunaApp());

class LunaApp extends StatelessWidget {
  const LunaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Luna Health',
      theme: ThemeData(primarySwatch: Colors.pink, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
