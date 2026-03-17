import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Luna"), centerTitle: false, actions: [
        IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile')),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCycleIndicator(),
            const SizedBox(height: 24),
            const Text("Сьогодні",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildStatusCard("Настрій", "Спокійний", Icons.sentiment_satisfied),
            _buildStatusCard("Симптоми", "Відсутні", Icons.health_and_safety),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
          color: Colors.pink[50], borderRadius: BorderRadius.circular(16)),
      child: const Column(
        children: [
          Text("ФАЗА ЦИКЛУ",
              style: TextStyle(
                  letterSpacing: 1.2, fontSize: 12, color: Colors.pink)),
          SizedBox(height: 8),
          Text("Фолікулярна",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text("День 12",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String val, IconData icon) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
          leading: Icon(icon), title: Text(title), subtitle: Text(val)),
    );
  }
}
