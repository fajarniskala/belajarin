import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller untuk menangkap input teks
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Controller Khusus Guru
  final TextEditingController _nipController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController(); // Mata Pelajaran
  final TextEditingController _bioController = TextEditingController();     // Bio

  // Variabel state
  String _selectedRole = 'parent';
  bool _isLoading = false;

  // Fungsi untuk mengirim data ke API CI4
  Future<void> _registerUser() async {
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty) {
      _showSnackBar('Nama, Email, dan Password wajib diisi!', Colors.orange);
      return;
    }

    if (_selectedRole == 'guru' && _nipController.text.isEmpty) {
      _showSnackBar('NIP wajib diisi untuk Guru!', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    const String apiUrl = '${ApiConfig.apiUrl}/register';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'role': _selectedRole,
          
          // Kirim data khusus guru jika role == guru
          'nip': _selectedRole == 'guru' ? _nipController.text : '', 
          'subject_specialization': _selectedRole == 'guru' ? _subjectController.text : '',
          'bio': _selectedRole == 'guru' ? _bioController.text : '',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        _showSnackBar('Berhasil Mendaftar!', Colors.green);
        
        // Kosongkan semua field
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _nipController.clear();
        _subjectController.clear();
        _bioController.clear();
        setState(() => _selectedRole = 'parent');
        
      } else {
        String errorMsg = 'Gagal mendaftar: Error ${response.statusCode}';
        try {
          final errData = json.decode(response.body);
          errorMsg = errData['messages']['error'] ?? errData['message'] ?? errorMsg;
        } catch (e) {
          errorMsg = response.body.length > 100 ? response.body.substring(0, 100) : response.body;
        }
        _showSnackBar(errorMsg, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Gagal terhubung ke server. Pastikan API menyala.', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nipController.dispose();
    _subjectController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Buat Akun Baru', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4A90E2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Ubah panah back jadi putih
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat Datang di BelajarIn 👋',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan isi form di bawah ini untuk mendaftar.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              _buildTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _emailController,
                label: 'Alamat Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 16),

              const Text('Daftar Sebagai:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: const [
                  DropdownMenuItem(value: 'parent', child: Text('Orang Tua (Pemantau)')),
                  DropdownMenuItem(value: 'guru', child: Text('Guru (Pembuat Modul)')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // FORM KHUSUS GURU
              if (_selectedRole == 'guru')
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nipController,
                        label: 'Nomor Induk Pegawai (NIP)',
                        icon: Icons.pin_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _subjectController,
                        label: 'Mata Pelajaran Spesialisasi',
                        icon: Icons.menu_book_outlined,
                      ),
                      const SizedBox(height: 16),

                      // Text Area untuk Bio (maxLines diset ke 3)
                      _buildTextField(
                        controller: _bioController,
                        label: 'Bio / Deskripsi Singkat',
                        icon: Icons.info_outline,
                        maxLines: 3, 
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white, 
                            strokeWidth: 2.5
                          ),
                        )
                      : const Text(
                          'Daftar Sekarang',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET HELPER
  // Ditambahkan parameter maxLines agar bisa jadi Text Area
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines, // Password harus selalu 1 baris
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 48.0 : 0.0), // Atur ikon agar tetap di atas jika text area
          child: Icon(icon),
        ),
        alignLabelWithHint: true, // Label sejajar di atas untuk Text Area
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A90E2)),
        ),
      ),
    );
  }
}