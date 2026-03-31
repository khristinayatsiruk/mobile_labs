import 'package:flutter/material.dart';
import 'package:luna_app/components/custom_button.dart';
import 'package:luna_app/components/custom_textfield.dart';
import 'package:luna_app/models/user_model.dart'; // Імпортуємо модель
import 'package:luna_app/repositories/auth_repository.dart'; // Імпортуємо репозиторій

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Контролери для зчитування тексту з полів
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Створюємо екземпляр репозиторію для роботи з пам'яттю
  final AuthRepository _authRepository = AuthRepository();

  // Основна функція входу
  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Валідація на порожні поля
    if (email.isEmpty || password.isEmpty) {
      _showError('Будь ласка, заповніть усі поля');
      return;
    }

    // 2. Отримуємо дані користувача, які ми зберегли при реєстрації
    final User? savedUser = await _authRepository.getUser();

    // 3. Перевіряємо логіку (Business Logic)
    if (savedUser != null &&
        savedUser.email == email &&
        savedUser.password == password) {
      // Якщо дані збігаються — переходимо на головну
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      // Якщо юзера немає або пароль не той
      _showError('Невірний email або пароль. Спробуйте ще раз!');
    }
  }

  // Зручний метод для показу помилок
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
    // Обов'язково очищуємо пам'ять (вимога лаби про ресурси)
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
