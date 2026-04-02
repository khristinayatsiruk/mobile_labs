import 'package:flutter/material.dart';
import 'package:luna_app/components/custom_button.dart';
import 'package:luna_app/components/custom_textfield.dart';
import 'package:luna_app/repositories/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthRepository _authRepository = AuthRepository();

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Будь ласка, заповніть усі поля');
      return;
    }

    final user = await _authRepository.getUserByEmail(email);

    if (user != null && user.password == password) {
      await _authRepository.setCurrentUser(email);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      _showError('Невірний email або пароль. Спробуйте ще раз!');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Luna Health',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Вітаємо знову! Увійдіть у свій акаунт.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Поле Email
              CustomTextField(
                hint: 'Email',
                controller: _emailController,
              ),

              // Поле Пароль
              CustomTextField(
                hint: 'Пароль',
                isPassword: true,
                controller: _passwordController,
              ),

              const SizedBox(height: 32),

              // Кнопка входу
              CustomButton(
                text: 'Увійти',
                onPressed: _handleLogin,
              ),

              const SizedBox(height: 16),

              // Перехід на реєстрацію
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Немає акаунта? ',
                      style: TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: 'Створити зараз',
                          style: TextStyle(
                            color: Colors.pinkAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
