import 'package:flutter/material.dart';
import 'package:luna_app/components/custom_button.dart';
import 'package:luna_app/components/custom_textfield.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black),),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Реєстрація',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
            const SizedBox(height: 30),
            const CustomTextField(hint: "Ім'я"),
            const CustomTextField(hint: 'Email'),
            const CustomTextField(hint: 'Пароль', isPassword: true),
            const SizedBox(height: 30),
            CustomButton(
                text: 'Зареєструватися',
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/home'),),
          ],
        ),
      ),
    );
  }
}
