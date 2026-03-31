import 'package:flutter/material.dart';

void main() => runApp(const LunaApp());

class LunaApp extends StatelessWidget {
  const LunaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const HealthPage(),
    );
  }
}

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  int _waterGlasses = 0;
  String _message = "Привіт! Скільки води вип'ємо сьогодні?";
  final TextEditingController _controller = TextEditingController();

  void _updateHealth() {
    final String text = _controller.text.trim();
    setState(() {
      if (text.toLowerCase() == 'lilo') {
        _waterGlasses = 0;
        _message = 'Магічне скидання! Починаємо заново ✨';
      } else {
        final int? addedWater = int.tryParse(text);
        if (addedWater != null) {
          _waterGlasses += addedWater;
          _message = 'Чудово! Гідратація — це важливо 💧';
        } else {
          _message = 'Введіть число або магічне слово!';
        }
      }
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        title: const Text('LunaSync: Women Health'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/SoftServe_logo.svg/1024px-SoftServe_logo.svg.png',
              width: 70,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.business, color: Colors.pink),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 40),
            const Icon(
              Icons.favorite,
              size: 100,
              color: Colors.pinkAccent,
            ),
            const SizedBox(height: 20),
            Text(
              'Випито води: $_waterGlasses скл.',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Введіть кількість (напр. 2)',
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: _updateHealth,
                child: const Text('Оновити дані'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
