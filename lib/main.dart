import 'package:flutter/material.dart';
import 'pages/login_page.dart'; // Import halaman login
import 'pages/home_page.dart'; // Import halaman Home setelah login
import 'pages/setting_page.dart'; // Import halaman Setting setelah login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Menambahkan routes di sini
      initialRoute: '/login', // Menentukan halaman pertama yang dibuka
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/setting': (context) => const SettingPage(),
      },
    );
  }
}
