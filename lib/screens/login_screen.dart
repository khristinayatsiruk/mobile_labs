import 'package:flutter/material.dart';
import 'package:luna_app/components/custom_button.dart';
import 'package:luna_app/components/custom_textfield.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Luna Health',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),),
            const SizedBox(height: 40),
            const CustomTextField(hint: 'Email'),
            const CustomTextField(hint: 'Пароль', isPassword: true),
            const SizedBox(height: 24),
            CustomButton(
                text: 'Увійти',
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/home'),),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Створити акаунт',
                    style: TextStyle(color: Colors.black),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
