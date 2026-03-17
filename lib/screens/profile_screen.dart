import 'package:flutter/material.dart';
import '../components/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Профіль")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.black,
                child: Icon(Icons.person, color: Colors.white)),
            const SizedBox(height: 16),
            const Text("Користувач Luna",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            const Divider(),
            ListTile(
                title: const Text("Налаштування"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16)),
            ListTile(
                title: const Text("Допомога"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16)),
            const SizedBox(height: 40),
            CustomButton(
                text: "Вийти",
                color: Colors.redAccent,
                onPressed: () => Navigator.pushReplacementNamed(context, '/')),
          ],
        ),
      ),
    );
  }
}
