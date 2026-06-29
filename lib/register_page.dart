import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api_config.dart';

class RegisterPage extends StatefulWidget {
  // Parameter untuk menerima status role dari halaman login
  final bool initialIsAnak;

  // Default true (anak) jika dipanggil tanpa parameter
  const RegisterPage({super.key, this.initialIsAnak = true});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Variabel internal untuk menyimpan status role tanpa menampilkannya di UI
  late bool isAnakSelected;

  // Controller untuk mengambil text dari input form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set nilai role berdasarkan parameter yang dikirim saat halaman dibuka
    isAnakSelected = widget.initialIsAnak;
  }

  // Fungsi untuk Hit API Register CodeIgniter 4
  Future<void> _register() async {
    // Validasi dasar client-side
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnackBar('Semua field wajib diisi!', Colors.orange);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Konfirmasi password tidak cocok!', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Sesuaikan URL dengan API Config Anda
    const String apiUrl = '${ApiConfig.apiUrl}/register_via_login';

    // Menentukan role secara otomatis berdasarkan parameter halaman
    final String selectedRole = isAnakSelected ? 'child' : 'parent';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'conf_password': _confirmPasswordController.text,
          'role': selectedRole,
        }),
      );

      // ===== DEBUGGING =====
      print('=== CEK BALASAN SERVER (REGISTER) ===');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=====================================');

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        _showSnackBar(
          'Server merespons format yang salah (Bukan JSON). Cek console log!',
          Colors.red,
        );
        return;
      }

      if (responseData is Map<String, dynamic>) {
        if (response.statusCode == 201 || responseData['status'] == true) {
          _showSnackBar(
            responseData['message'] ?? 'Registrasi Berhasil!',
            Colors.green,
          );
          // Kembali ke halaman login setelah sukses
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context);
          });
        } else {
          String errorMessage = responseData['message'] ?? 'Registrasi Gagal';
          if (responseData['errors'] != null && responseData['errors'] is Map) {
            errorMessage = responseData['errors'].values.first.toString();
          }
          _showSnackBar(errorMessage, Colors.red);
        }
      } else {
        _showSnackBar(
          'Struktur balasan dari server tidak dikenali',
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar('Tidak dapat terhubung ke server: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 87, 121, 245),
              Color.fromARGB(255, 191, 144, 253),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 30.0,
            ),
            child: Column(
              children: [
                // Header Logo & Judul "BelajarIn"
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      size: 42,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'BelajarIn',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 4.0,
                            color: Colors.black.withOpacity(0.15),
                            offset: const Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Card Form Putih Melengkung
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          // Menampilkan judul dinamis sesuai dengan registrasi role yang dituju
                          isAnakSelected
                              ? 'Buat Akun Anak'
                              : 'Buat Akun Orang Tua',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // [TAB PILIHAN ROLE TELAH DIHAPUS DARI SINI]

                      // Input Nama Lengkap
                      const Text(
                        'Nama Lengkap',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameController,
                        hintText: 'masukkan nama lengkap...',
                      ),
                      const SizedBox(height: 16),

                      // Input Email
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'masukkan email...',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Input Password
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: '••••••••',
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),

                      // Input Konfirmasi Password
                      const Text(
                        'Konfirmasi Password',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hintText: '••••••••',
                        obscureText: true,
                      ),
                      const SizedBox(height: 30),

                      // Tombol Daftar Sekarang
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4D96FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Daftar Sekarang',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Teks Link Kembali ke Login
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: RichText(
                            text: const TextSpan(
                              text: 'Sudah punya akun? ',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Masuk',
                                  style: TextStyle(
                                    color: Color(0xFF4D96FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Footer Tech Stack
                      Center(
                        child: Text(
                          'Flutter • CodeIgniter 4 • MySQL',
                          style: TextStyle(
                            color: Colors.grey.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF4D96FF), width: 1.5),
        ),
      ),
    );
  }
}
