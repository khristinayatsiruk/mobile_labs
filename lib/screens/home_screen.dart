import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Додано для PlatformException
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luna_app/logic/home_cubit.dart';
import 'package:luna_app/logic/symptoms_cubit.dart';
import 'package:luna_app/services/mqtt_service.dart';
import 'package:my_flashlight_plugin/my_flashlight_plugin.dart'; // Імпорт твого плагіна

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MqttService _mqttService = MqttService();
  String _temperature = '--';
  bool _isFlashOn = false; // Стан ліхтарика

  @override
  void initState() {
    super.initState();
    _initMqtt();
  }

  void _initMqtt() async {
    await _mqttService.connect();
    _mqttService.tempStream.listen((data) {
      if (mounted) setState(() => _temperature = data);
    });
  }

  // Метод для керування ліхтариком
  void _handleFlashlight() async {
    try {
      setState(() => _isFlashOn = !_isFlashOn);
      await MyFlashlightPlugin.toggle(_isFlashOn);
    } catch (e) {
      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (diagContext) => AlertDialog(
            title: const Text('Попередження'),
            content: Text(e is PlatformException ? e.message! : e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(diagContext),
                child: const Text('Зрозуміло'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showSymptomDialog(
    BuildContext context, {
    int? index,
    String? initialValue,
  }) {
    final controller = TextEditingController(text: initialValue);
    showDialog<void>(
      context: context,
      builder: (diagContext) => AlertDialog(
        title: Text(index == null ? 'Додати симптом' : 'Редагувати симптом'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Як ви почуваєтесь?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(diagContext),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () {
              if (index == null) {
                context.read<SymptomsCubit>().addSymptom(controller.text);
              } else {
                context
                    .read<SymptomsCubit>()
                    .editSymptom(index, controller.text);
              }
              Navigator.pop(diagContext);
            },
            child: const Text('Зберегти'),
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
          // СЕКРЕТНА КНОПКА ЛІХТАРИКА
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: _isFlashOn ? Colors.yellow : null,
            ),
            onPressed: _handleFlashlight,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<HomeCubit>().fetchHomeData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCycleCard(),
              const SizedBox(height: 24),
              _buildMqttCard(),
              const SizedBox(height: 24),
              const Text(
                'Поради Luna (via Cubit)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    children: state.tips
                        .map(
                          (tip) => Card(
                            color: Colors.pink[50],
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(
                                Icons.auto_awesome,
                                color: Colors.pink,
                              ),
                              title: Text(tip['title']?.toString() ?? 'Порада'),
                              subtitle:
                                  Text(tip['description']?.toString() ?? ''),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ваші симптоми',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => _showSymptomDialog(context),
                    icon: const Icon(Icons.add_circle, color: Colors.pink),
                  ),
                ],
              ),
              BlocBuilder<SymptomsCubit, List<String>>(
                builder: (context, symptoms) {
                  return Column(
                    children: symptoms
                        .asMap()
                        .entries
                        .map(
                          (entry) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(
                                Icons.bubble_chart,
                                color: Colors.pinkAccent,
                              ),
                              title: Text(entry.value),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => _showSymptomDialog(
                                      context,
                                      index: entry.key,
                                      initialValue: entry.value,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => context
                                        .read<SymptomsCubit>()
                                        .deleteSymptom(entry.key),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMqttCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.thermostat, color: Colors.blue),
            const SizedBox(width: 16),
            Text(
              '$_temperature°C',
              style:
                  // ignore: lines_longer_than_80_chars
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );

  Widget _buildCycleCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.pink[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'День 12',
            style: TextStyle(fontSize: 40, color: Colors.pink),
          ),
        ),
      );
}
