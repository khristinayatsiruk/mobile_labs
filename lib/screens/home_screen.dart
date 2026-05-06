import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:luna_app/services/api_service.dart';
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
  String _temperature = '--';

  @override
  void initState() {
    super.initState();
    _loadSymptoms();
    _initMqtt();
  }

  Future<void> _initMqtt() async {
    final result = await Connectivity().checkConnectivity();
    if (!result.contains(ConnectivityResult.none)) {
      await _mqttService.connect();
      _mqttService.tempStream.listen((data) {
        if (mounted) setState(() => _temperature = data);
      });
    }
  }

  Future<void> _loadSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
        () => _symptoms = prefs.getStringList('user_symptoms') ?? ['Відсутні']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Luna',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCycleCard(),
            const SizedBox(height: 24),
            _buildMqttCard(),
            const SizedBox(height: 24),
            const Text('Поради Luna (API)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            FutureBuilder<List<dynamic>>(
              future: ApiService.getTips(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Поради завантажуються...');
                }

                final tips = snapshot.data ?? [];
                if (tips.isEmpty) return const Text('Поради недоступні');

                return Column(
                  children: tips.map((dynamic item) {
                    // Перетворюємо dynamic в Map, щоб зникли червоні лінії
                    final tip = item as Map<String, dynamic>;
                    return Card(
                      color: Colors.pink[50],
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading:
                            const Icon(Icons.auto_awesome, color: Colors.pink),
                        title: Text(tip['title']?.toString() ?? 'Порада'),
                        subtitle: Text(tip['description']?.toString() ?? ''),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Ваші симптоми',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ..._symptoms.map((s) => Card(child: ListTile(title: Text(s)))),
          ],
        ),
      ),
    );
  }

  Widget _buildMqttCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.thermostat, color: Colors.blue),
          const SizedBox(width: 16),
          Text('$_temperature°C',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ]),
      );

  Widget _buildCycleCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
            color: Colors.pink[50], borderRadius: BorderRadius.circular(16)),
        child: const Center(
            child: Text('День 12',
                style: TextStyle(fontSize: 40, color: Colors.pink))),
      );
}
