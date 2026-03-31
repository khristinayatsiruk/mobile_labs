import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Список симптомів (будемо зберігати як список рядків)
  List<String> _symptoms = [];

  @override
  void initState() {
    super.initState();
    _loadSymptoms(); // Завантажуємо при старті
  }

  // --- ЛОГІКА РОБОТИ З ДАНИМИ (CRUD) ---

  // 1. Читання (Read)
  Future<void> _loadSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _symptoms = prefs.getStringList('user_symptoms') ?? ['Відсутні'];
    });
  }

  // 2. Збереження (Create / Update)
  Future<void> _saveSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_symptoms', _symptoms);
  }

  // Функція для додавання нового симптому
  void _addSymptom(String symptom) {
    setState(() {
      if (_symptoms.contains('Відсутні')) {
        _symptoms.clear(); // Видаляємо заглушку, якщо додаємо реальний симптом
      }
      _symptoms.add(symptom);
    });
    _saveSymptoms();
  }

  // 3. Видалення (Delete)
  void _deleteSymptom(int index) {
    setState(() {
      _symptoms.removeAt(index);
      if (_symptoms.isEmpty) {
        _symptoms.add('Відсутні');
      }
    });
    _saveSymptoms();
  }

  // --- UI КОМПОНЕНТИ ---

  // Діалогове вікно для введення
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
      // Кнопка "+" для додавання симптомів
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
            const Text(
              'Сьогодні',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Картка настрою (статична)
            _buildStatusCard(
              'Настрій',
              'Спокійний',
              Icons.sentiment_satisfied,
              null,
            ),

            // ДИНАМІЧНИЙ СПИСОК СИМПТОМІВ
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
                    () => _deleteSymptom(index), // Передаємо функцію видалення
                  );
                },
              ),
            ),
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
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Text(
            'ФАЗА ЦИКЛУ',
            style: TextStyle(
              letterSpacing: 1.2,
              fontSize: 12,
              color: Colors.pink,
            ),
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

  Widget _buildStatusCard(
    String title,
    String val,
    IconData icon,
    VoidCallback? onDelete,
  ) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.pink[300]),
        title: Text(title),
        subtitle: Text(val),
        trailing: onDelete != null && title != 'Відсутні'
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }
}
