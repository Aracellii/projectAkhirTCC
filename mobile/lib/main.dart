import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home.dart';
import 'screens/input_product.dart';
import 'screens/track_product.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const LoginPage(),
        '/register': (ctx) => const RegisterPage(),
        '/home': (ctx) => const HomePage(),
        '/track-product': (ctx) => const TrackProductPage(),
        '/products': (_) => const ProductListPage(),
      },
    );
  }
}
