class User {
  final String name;
  final String email;
  final String password;

  User({required this.name, required this.email, required this.password});

  // Перетворюємо в JSON, щоб зберегти в сторедж
  Map<String, String> toMap() {
    return {'name': name, 'email': email, 'password': password};
  }

  // Створюємо об'єкт з пам'яті
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      // Додаємо "as String", щоб заспокоїти компілятор
      name: (map['name'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      password: (map['password'] ?? '') as String,
    );
  }
}
