import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  void _handleLogin() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showError('Відсутнє підключення до інтернету!');
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Будь ласка, заповніть усі поля');
      return;
    }

    // ignore: use_build_context_synchronously
    final authRepository = context.read<AuthRepository>();
    final user = await authRepository.getUserByEmail(email);

    if (user != null && user.password == password) {
      await authRepository.setCurrentUser(email);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      _showError('Невірний email або пароль!');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
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
              const SizedBox(height: 40),
              CustomTextField(hint: 'Email', controller: _emailController),
              CustomTextField(
                hint: 'Пароль',
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 32),
              CustomButton(text: 'Увійти', onPressed: _handleLogin),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Немає акаунта? Створити зараз'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
