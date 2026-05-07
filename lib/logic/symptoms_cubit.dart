import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SymptomsCubit extends Cubit<List<String>> {
  SymptomsCubit() : super([]);

  Future<void> loadSymptoms() async {
    final prefs = await SharedPreferences.getInstance();
    emit(prefs.getStringList('user_symptoms') ?? []);
  }

  Future<void> _save(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_symptoms', list);
  }

  void addSymptom(String s) async {
    final newList = List<String>.from(state)..add(s);
    await _save(newList);
    emit(newList);
  }

  void deleteSymptom(int i) async {
    final newList = List<String>.from(state)..removeAt(i);
    await _save(newList);
    emit(newList);
  }

  void editSymptom(int i, String s) async {
    final newList = List<String>.from(state);
    newList[i] = s;
    await _save(newList);
    emit(newList);
  }
}
