import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  void _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Заповніть усі поля!');
      return;
    }

    final newUser = User(name: name, email: email, password: password);

    // ВАЖЛИВО: Отримуємо той самий єдиний екземпляр репозиторію
    await context.read<AuthRepository>().saveUser(newUser);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Реєстрація успішна!')),
      );
      Navigator.pop(context);
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
