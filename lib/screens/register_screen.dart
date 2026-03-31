import 'package:flutter/material.dart';
import 'package:luna_app/components/custom_button.dart';
import 'package:luna_app/components/custom_textfield.dart';
import 'package:luna_app/models/user_model.dart';
import 'package:luna_app/repositories/auth_repository.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Створюємо екземпляр нашого репозиторію
  final AuthRepository _authRepository = AuthRepository();

  void _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // ВАЛІДАЦІЯ (вимога лаби)
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Заповніть усі поля!');
      return;
    }
    if (!email.contains('@')) {
      _showError('Некоректний Email!');
      return;
    }
    if (password.length < 6) {
      _showError('Пароль має бути не менше 6 символів!');
      return;
    }

    // Створюємо модель користувача
    final newUser = User(name: name, email: email, password: password);

    // Зберігаємо в локальне сховище
    await _authRepository.saveUser(newUser);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Реєстрація успішна! Тепер увійдіть.')),
      );
      Navigator.pop(context); // Повертаємось на екран логіна
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Реєстрація')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CustomTextField(hint: "Ім'я", controller: _nameController),
            CustomTextField(hint: 'Email', controller: _emailController),
            CustomTextField(
              hint: 'Пароль',
              isPassword: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 24),
            CustomButton(text: 'Зареєструватися', onPressed: _register),
          ],
        ),
      ),
    );
  }
}
