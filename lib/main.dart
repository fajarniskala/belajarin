import 'package:flutter/material.dart';
// Pastikan file admin_dashboard_screen.dart berada di folder yang sama
// atau sesuaikan path import di bawah ini jika letaknya berbeda.
import 'admin_dashboard_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BelajarIn Admin',
      debugShowCheckedModeBanner: false, // Menghilangkan pita "DEBUG" di pojok kanan atas
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A90E2)),
        useMaterial3: true,
      ),
      // Mengubah home agar langsung memuat halaman Dashboard Admin
      home: const AdminDashboardScreen(), 
    );
  }
}