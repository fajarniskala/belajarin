import 'package:flutter/material.dart';
// Pastikan nama file sesuai dengan nama file login yang kamu buat sebelumnya
import 'login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BelajarIn',
      debugShowCheckedModeBanner:
          false, // Menghilangkan pita "DEBUG" di pojok kanan atas
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A90E2)),
        useMaterial3: true,
      ),
      // Mengubah home agar langsung memuat halaman Login
      home: const LoginScreen(),
    );
  }
}
