import 'dart:convert';
import 'package:luna_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IAuthRepository {
  Future<void> saveUser(User user);
  Future<User?> getUserByEmail(String email);
  Future<List<User>> getAllUsers();
  Future<void> setCurrentUser(String email);
  Future<User?> getCurrentUser();
  Future<void> logout();
}

class AuthRepository implements IAuthRepository {
  static const String _usersListKey = 'all_users_list';
  static const String _currentUserEmailKey = 'current_user_email';

  @override
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getAllUsers();
    final index = users.indexWhere((u) => u.email == user.email);
    if (index != -1) {
      users[index] = user;
    } else {
      users.add(user);
    }
    final encodedData = jsonEncode(users.map((u) => u.toMap()).toList());
    await prefs.setString(_usersListKey, encodedData);
  }

  @override
  Future<void> setCurrentUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserEmailKey, email);
  }

  @override
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_currentUserEmailKey);
    if (email == null) return null;
    return getUserByEmail(email);
  }

  @override
  Future<List<User>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersListKey);
    if (usersJson != null) {
      final decodedData = jsonDecode(usersJson) as List<dynamic>;
      return decodedData
          .map((item) => User.fromMap(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserEmailKey);
  }
}
