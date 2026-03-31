import 'package:flutter/material.dart';
import 'package:luna_app/models/user_model.dart';
import 'package:luna_app/repositories/auth_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = await _authRepository.getUser();
    setState(() {
      _currentUser = user;
    });
  }

  void _logout() async {
    await _authRepository.logout();
    if (mounted) {
      // Очищуємо весь стек екранів і повертаємось на Логін
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мій Профіль')),
      body: Center(
        child: _currentUser == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 100,
                    color: Colors.pinkAccent,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Ім'я: ${_currentUser!.name}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Email: ${_currentUser!.email}',
                    // ignore: lines_longer_than_80_chars
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text('Вийти з акаунта'),
                  ),
                ],
              ),
      ),
    );
  }
}
