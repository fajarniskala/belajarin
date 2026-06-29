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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nipController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String _selectedRole = 'parent';
  bool _isLoading = false;

  // State untuk Dropdown Mata Pelajaran
  List<dynamic> _categories = [];
  String? _selectedSubject;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Ambil data kategori saat halaman dibuka
  }

  // Fungsi memanggil API kategori dari CI4
  Future<void> _fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/categorycontroller/categories'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _categories = jsonDecode(response.body);
          _isLoadingCategories = false;
        });
      } else {
        _showSnackBar('Gagal memuat mata pelajaran', Colors.red);
        setState(() => _isLoadingCategories = false);
      }
    } catch (e) {
      _showSnackBar('Error memuat kategori: $e', Colors.red);
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _registerUser() async {
    // Validasi dasar
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('Nama, Email, dan Password wajib diisi!', Colors.orange);
      return;
    }

    // Validasi khusus Guru
    if (_selectedRole == 'guru') {
      if (_nipController.text.trim().isEmpty) {
        _showSnackBar('NIP wajib diisi untuk Guru!', Colors.orange);
        return;
      }
      if (_selectedSubject == null) {
        _showSnackBar(
          'Mata Pelajaran Spesialisasi wajib dipilih!',
          Colors.orange,
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    // Susun body JSON
    final Map<String, dynamic> body = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'role': _selectedRole,
    };

    // Tambahkan field guru hanya jika diperlukan
    if (_selectedRole == 'guru') {
      body['nip'] = _nipController.text.trim();
      body['subject_specialization'] =
          _selectedSubject; // Menggunakan value dari dropdown
      body['bio'] = _bioController.text.trim();
    }

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.apiUrl}/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('=== REGISTER RESPONSE ===');
      debugPrint('Status : ${response.statusCode}');
      debugPrint('Body   : ${response.body}');
      debugPrint('=========================');

      Map<String, dynamic>? resData;
      try {
        resData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        _showSnackBar('Server merespons format tidak valid.', Colors.red);
        return;
      }

      if (response.statusCode == 201) {
        _showSnackBar(
          resData['message'] ?? 'Registrasi berhasil!',
          Colors.green,
        );
        _clearForm();

        // Kembali ke halaman sebelumnya setelah 1.5 detik
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) Navigator.pop(context);
      } else {
        final String errorMsg =
            resData['messages']?['error'] ??
            resData['message'] ??
            'Gagal mendaftar (${response.statusCode})';
        _showSnackBar(errorMsg, Colors.red);
      }
    } on http.ClientException catch (e) {
      _showSnackBar('Koneksi gagal: ${e.message}', Colors.red);
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _nipController.clear();
    _bioController.clear();
    setState(() {
      _selectedRole = 'parent';
      _selectedSubject = null; // Reset dropdown mapel
    });
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
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
    _nipController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Buat Akun Baru',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4A90E2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat Datang di BelajarIn',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Isi form di bawah ini untuk mendaftar.',
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

              // Dropdown Role
              const Text(
                'Daftar Sebagai:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4A90E2)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'parent',
                    child: Text('Orang Tua (Pemantau)'),
                  ),
                  DropdownMenuItem(
                    value: 'guru',
                    child: Text('Guru (Pembuat Modul)'),
                  ),
                ],
                onChanged: (value) => setState(() {
                  _selectedRole = value!;
                  // Reset subject bila ganti role
                  if (value != 'guru') _selectedSubject = null;
                }),
              ),

              // Form Khusus Guru — muncul animasi saat dipilih
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _selectedRole == 'guru'
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _nipController,
                            label: 'Nomor Induk Pegawai (NIP)',
                            icon: Icons.pin_outlined,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          // --- UI DROPDOWN MAPEL ---
                          _isLoadingCategories
                              ? Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Text(
                                        'Memuat mata pelajaran...',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                )
                              : DropdownButtonFormField<String>(
                                  value: _selectedSubject,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: 'Mata Pelajaran Spesialisasi',
                                    prefixIcon: const Icon(
                                      Icons.menu_book_outlined,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF4A90E2),
                                      ),
                                    ),
                                  ),
                                  items: _categories
                                      .map<DropdownMenuItem<String>>((
                                        category,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: category['name'].toString(),
                                          child: Text(
                                            category['name'].toString(),
                                          ),
                                        );
                                      })
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSubject = value;
                                    });
                                  },
                                ),

                          // -------------------------
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _bioController,
                            label: 'Bio / Deskripsi Singkat',
                            icon: Icons.info_outline,
                            maxLines: 3,
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    disabledBackgroundColor: const Color(
                      0xFF4A90E2,
                    ).withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Sudah punya akun? ',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Masuk',
                          style: TextStyle(
                            color: Color(0xFF4A90E2),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
      maxLines: obscureText ? 1 : maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 48.0 : 0.0),
          child: Icon(icon),
        ),
        alignLabelWithHint: true,
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
