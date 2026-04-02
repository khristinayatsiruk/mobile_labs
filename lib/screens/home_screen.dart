import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:luna_app/services/mqtt_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _symptoms = [];
  final MqttService _mqttService = MqttService();
  String _temperature = '--'; // Початкове значення для MQTT

  @override
  void initState() {
    super.initState();
    _loadSymptoms();
    _initConnectivityAndMqtt();
  }

  // Ініціалізація мережі та MQTT
  Future<void> _initConnectivityAndMqtt() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    // Якщо інтернету немає — попереджаємо (вимога ЛР4)
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Працюємо офлайн. Дані MQTT недоступні.'),
          ),
        );
      }
    } else {
      // Якщо інтернет є — підключаємо MQTT
      await _mqttService.connect();
      _mqttService.tempStream.listen((data) {
        if (mounted) {
          setState(() {
            _temperature = data;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _mqttService.disconnect(); // Важливо закривати з'єднання
    super.dispose();
  }

  // --- ЛОГІКА CRUD (без змін) ---
  Future<void> _loadSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _symptoms = prefs.getStringList('user_symptoms') ?? ['Відсутні'];
    });
  }

  Future<void> _saveSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_symptoms', _symptoms);
  }

  void _addSymptom(String symptom) {
    setState(() {
      if (_symptoms.contains('Відсутні')) _symptoms.clear();
      _symptoms.add(symptom);
    });
    _saveSymptoms();
  }

  void _deleteSymptom(int index) {
    setState(() {
      _symptoms.removeAt(index);
      if (_symptoms.isEmpty) _symptoms.add('Відсутні');
    });
    _saveSymptoms();
  }

  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Додати симптом'),
        content: TextField(
          controller: controller,
          decoration:
              const InputDecoration(hintText: 'Наприклад: Головний біль'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addSymptom(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Додати'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Luna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.pink[200],
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCycleIndicator(),
            const SizedBox(height: 24),

            // ВІДЖЕТ MQTT ДАНИХ (Лабораторна 4)
            _buildMqttDataCard(),

            const SizedBox(height: 24),
            const Text(
              'Сьогодні',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildStatusCard(
              'Настрій',
              'Спокійний',
              Icons.sentiment_satisfied,
              null,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Ваші симптоми:',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _symptoms.length,
                itemBuilder: (context, index) {
                  return _buildStatusCard(
                    _symptoms[index],
                    'Симптом',
                    Icons.health_and_safety,
                    () => _deleteSymptom(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Новий віджет для температури з IoT датчика
  Widget _buildMqttDataCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.thermostat, color: Colors.blue[800], size: 30),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Температура тіла',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '$_temperature°C',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCycleIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Text(
            'ФАЗА ЦИКЛУ',
            style:
                TextStyle(letterSpacing: 1.2, fontSize: 12, color: Colors.pink),
          ),
          SizedBox(height: 8),
          Text(
            'Фолікулярна',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'День 12',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String t, String v, IconData i, VoidCallback? d) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(i, color: Colors.pink[300]),
        title: Text(t),
        subtitle: Text(v),
        trailing: d != null && t != 'Відсутні'
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: d,
              )
            : null,
      ),
    );
  }
}
