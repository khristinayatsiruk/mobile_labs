import 'dart:convert';

import 'package:luna_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IAuthRepository {
  Future<void> saveUser(User user);
  Future<User?> getUser();
  Future<void> logout();
}

class AuthRepository implements IAuthRepository {
  static const String _userKey = 'saved_user';

  @override
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final String userJson = jsonEncode(user.toMap());
    await prefs.setString(_userKey, userJson);
  }

  @override
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(_userKey);

    if (userJson != null) {
      final Map<String, dynamic> userMap =
          jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromMap(userMap);
    }
    return null;
  }

  @override
  Future<void> logout() async {
    // МИ НІЧОГО НЕ ВИДАЛЯЄМО ТУТ
    // Це дозволить користувачу зайти знову під тими ж даними.
    // ignore: lines_longer_than_80_chars
    // Якщо хочеш видалити саме "сесію", можна видаляти окремий ключ 'is_logged',
    // але не самого користувача.
  }
}
