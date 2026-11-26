import 'package:flutter/material.dart';
import 'vistas/vista_login.dart';
import 'diseño/diseño_app.dart';

void main() => runApp(const MonedasApp());

class MonedasApp extends StatelessWidget {
  const MonedasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monexis',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const LoginScreen(),
    );
  }
}