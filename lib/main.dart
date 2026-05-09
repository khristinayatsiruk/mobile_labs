import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:luna_app/logic/home_cubit.dart';
import 'package:luna_app/logic/profile_cubit.dart';
import 'package:luna_app/logic/symptoms_cubit.dart';
import 'package:luna_app/repositories/auth_repository.dart';
import 'package:luna_app/screens/home_screen.dart';
import 'package:luna_app/screens/login_screen.dart';
import 'package:luna_app/screens/profile_screen.dart';
import 'package:luna_app/screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Створюємо репозиторій ОДИН РАЗ
  final authRepo = AuthRepository();
  final currentUser = await authRepo.getCurrentUser();

  runApp(
    RepositoryProvider.value(
      value: authRepo,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SymptomsCubit()..loadSymptoms()),
          BlocProvider(
            create: (context) => ProfileCubit(authRepo)..loadUserProfile(),
          ),
          BlocProvider(create: (context) => HomeCubit()..fetchHomeData()),
        ],
        child: MyApp(isLoggedIn: currentUser != null),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: isLoggedIn ? '/home' : '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
