import 'package:flutter/material.dart';
import 'package:e_library/screens/login_screen.dart';
import 'package:e_library/screens/signup_screen.dart';
import 'package:e_library/screens/home_screen.dart';
import 'package:e_library/models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Library',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const LoginScreen(),
      // Definir rutas nombradas
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
      },
      // Opcional: manejar rutas dinámicas
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          // Extraer argumentos
          final user = settings.arguments as User;
          return MaterialPageRoute(
            builder: (context) => HomeScreen(user: user),
          );
        }
        return null;
      },
      // Opcional: manejar rutas desconocidas
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      },
    );
  }
}
