import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luna_app/logic/home_cubit.dart';
import 'package:luna_app/logic/symptoms_cubit.dart';
import 'package:luna_app/services/mqtt_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MqttService _mqttService = MqttService();
  String _temperature = '--';

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

  // Діалог для створення та редагування симптомів (використовує SymptomsCubit)
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
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        // Оновлення порад через Cubit
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

              // Рендеринг порад з API через HomeCubit
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (state.tips.isEmpty) {
                    return const Text('Поради завантажуються...');
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

              // Заголовок секції симптомів
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

              // Динамічний список симптомів (CRUD) через SymptomsCubit
              BlocBuilder<SymptomsCubit, List<String>>(
                builder: (context, symptoms) {
                  if (symptoms.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Відсутні',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

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
                                      size: 20,
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
                                      size: 20,
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

  // Віджети-компоненти для чистоти коду
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
