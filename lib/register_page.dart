import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api_config.dart';

class RegisterPage extends StatefulWidget {
  final bool initialIsAnak;

  const RegisterPage({super.key, this.initialIsAnak = true});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _selectedRole = 'child';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final TextEditingController _nipController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isLoading = false;

  // State List Penampung Data dari API
  List<dynamic> _categories = [];
  List<dynamic> _parents = []; 
  List<dynamic> _teachers = []; // 🌟 Tambahan untuk menampung daftar guru aktif

  String? _selectedSubject;
  String? _selectedClass;
  String? _selectedParent; 
  String? _selectedTeacher; // 🌟 Tambahan untuk menampung pilihan ID Guru dari anak

  bool _isLoadingCategories = true;
  bool _isLoadingParents = true; 
  bool _isLoadingTeachers = true; // 🌟 Loading status daftar guru

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialIsAnak ? 'child' : 'parent';
    _fetchCategories();
    _fetchParents();
    _fetchTeachers(); // 🌟 Panggil fungsi load guru saat init
  }

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
        setState(() => _isLoadingCategories = false);
      }
    } catch (e) {
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _fetchParents() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/gurucontroller/parents'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _parents = responseData['data'] ?? [];
          _isLoadingParents = false;
        });
      } else {
        setState(() => _isLoadingParents = false);
      }
    } catch (e) {
      setState(() => _isLoadingParents = false);
    }
  }

  // 🌟 TAMBAHAN: Fetch daftar guru untuk dropdown registrasi mandiri anak
  Future<void> _fetchTeachers() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/dashboard/teachers'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _teachers = responseData['data'] ?? [];
          _isLoadingTeachers = false;
        });
      } else {
        setState(() => _isLoadingTeachers = false);
      }
    } catch (e) {
      setState(() => _isLoadingTeachers = false);
      debugPrint("Error load teachers: $e");
    }
  }

  Future<void> _register() async {
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

    // Validasi Relasi Khusus Role Anak (Wajib mengaitkan orang tua & guru)
    if (_selectedRole == 'child') {
      if (_selectedParent == null) {
        _showSnackBar('Silakan pilih nama Orang Tua / Wali Anda!', Colors.orange);
        return;
      }
      if (_selectedTeacher == null) {
        _showSnackBar('Silakan pilih nama Guru / Wali Kelas Anda!', Colors.orange);
        return;
      }
    }

    // Validasi Khusus Guru
    if (_selectedRole == 'guru') {
      if (_nipController.text.trim().isEmpty) {
        _showSnackBar('NIP wajib diisi untuk Guru!', Colors.orange);
        return;
      }
      if (_selectedSubject == null) {
        _showSnackBar('Mata Pelajaran wajib dipilih!', Colors.orange);
        return;
      }
      if (_selectedClass == null) {
        _showSnackBar('Kelas pengajaran wajib dipilih!', Colors.orange);
        return;
      }
    }

    setState(() => _isLoading = true);

    const String apiUrl = '${ApiConfig.apiUrl}/register_via_login';

    final Map<String, dynamic> requestBody = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'conf_password': _confirmPasswordController.text,
      'role': _selectedRole,
    };

    // 🌟 Suntik parent_id & guru_id ke payload JSON jika pendaftar adalah Anak
    if (_selectedRole == 'child') {
      requestBody['parent_id'] = _selectedParent;
      requestBody['guru_id'] = _selectedTeacher; // 🔥 Dikirim aman ke Auth.php
    }

    if (_selectedRole == 'guru') {
      requestBody['nip'] = _nipController.text.trim();
      requestBody['subject_specialization'] = _selectedSubject;
      requestBody['class_grade'] = _selectedClass;
      requestBody['bio'] = _bioController.text.trim();
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        _showSnackBar('Format respon server salah (Bukan JSON).', Colors.red);
        return;
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar(
          responseData['message'] ?? 'Registrasi Berhasil! Menunggu persetujuan Admin.',
          Colors.green,
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        String errorMessage = responseData['message'] ?? 'Registrasi Gagal';
        _showSnackBar(errorMessage, Colors.red);
      }
    } catch (e) {
      _showSnackBar('Tidak dapat terhubung ke server: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nipController.dispose();
    _bioController.dispose();
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
            colors: [Color(0xFF5779F5), Color(0xFFBF90FD)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.menu_book_rounded, size: 42, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      'BelajarIn',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 4.0, color: Colors.black.withOpacity(0.15), offset: const Offset(2.0, 2.0))],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Form Pembuatan Akun Baru',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text('Daftar Sebagai', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: _buildDropdownDecoration('Pilih Peran Akun'),
                        items: const [
                          DropdownMenuItem(value: 'child', child: Text('Anak (Siswa)')),
                          DropdownMenuItem(value: 'parent', child: Text('Orang Tua (Pemantau)')),
                          DropdownMenuItem(value: 'guru', child: Text('Guru (Tenaga Pendidik)')),
                        ],
                        onChanged: (value) => setState(() {
                          _selectedRole = value!;
                          _selectedParent = null; 
                          _selectedTeacher = null; // Reset dropdown guru jika ganti peran
                        }),
                      ),
                      const SizedBox(height: 16),

                      // 🌟 ANIMATED FORM INPUT KHUSUS RELASI AKUN ANAK (ORANG TUA & GURU WALI KELAS)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _selectedRole == 'child'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // DROPDOWN HUBUNGKAN ORANG TUA
                                  const Text('Nama Orang Tua / Wali', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
                                  const SizedBox(height: 8),
                                  _isLoadingParents
                                      ? const Padding(padding: EdgeInsets.all(8.0), child: LinearProgressIndicator(color: Color(0xFF4D96FF)))
                                      : DropdownButtonFormField<String>(
                                          value: _selectedParent,
                                          isExpanded: true,
                                          decoration: _buildDropdownDecoration('Hubungkan dengan Akun Orang Tua'),
                                          items: _parents.map<DropdownMenuItem<String>>((parent) {
                                            return DropdownMenuItem<String>(
                                              value: parent['id'].toString(),
                                              child: Text("${parent['name']} (${parent['email']})"),
                                            );
                                          }).toList(),
                                          onChanged: (val) => setState(() => _selectedParent = val),
                                        ),
                                  const SizedBox(height: 16),

                                  // 🔥 BARU: DROPDOWN HUBUNGKAN GURU / WALI KELAS SISWA
                                  const Text('Guru / Wali Kelas', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
                                  const SizedBox(height: 8),
                                  _isLoadingTeachers
                                      ? const Padding(padding: EdgeInsets.all(8.0), child: LinearProgressIndicator(color: Color(0xFF4D96FF)))
                                      : DropdownButtonFormField<String>(
                                          value: _selectedTeacher,
                                          isExpanded: true,
                                          decoration: _buildDropdownDecoration('Pilih Guru Pengajar Anda'),
                                          items: _teachers.map<DropdownMenuItem<String>>((guru) {
                                            return DropdownMenuItem<String>(
                                              value: guru['id'].toString(),
                                              child: Text("${guru['name']} (${guru['email']})"),
                                            );
                                          }).toList(),
                                          onChanged: (val) => setState(() => _selectedTeacher = val),
                                        ),
                                  const SizedBox(height: 16),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),

                      const Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
                      const SizedBox(height: 8),
                      _buildTextField(controller: _nameController, hintText: 'masukkan nama lengkap...'),
                      const SizedBox(height: 16),

                      const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
                      const SizedBox(height: 8),
                      _buildTextField(controller: _emailController, hintText: 'masukkan email...', keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 16),

                      // ANIMATED FORM INPUT KHUSUS DATA GURU
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _selectedRole == 'guru'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Nomor Induk Pegawai (NIP)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
                                  const SizedBox(height: 8),
                                  _buildTextField(controller: _nipController, hintText: 'masukkan NIP resmi...', keyboardType: TextInputType.number),
                                  const SizedBox(height: 16),

                                  const Text('Mata Pelajaran Spesialisasi', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
                                  const SizedBox(height: 8),
                                  _isLoadingCategories
                                      ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())
                                      : DropdownButtonFormField<String>(
                                          value: _selectedSubject,
                                          isExpanded: true,
                                          decoration: _buildDropdownDecoration('Pilih Spesialisasi Ilmu'),
                                          items: _categories.map<DropdownMenuItem<String>>((cat) {
                                            return DropdownMenuItem<String>(value: cat['name'].toString(), child: Text(cat['name'].toString()));
                                          }).toList(),
                                          onChanged: (val) => setState(() => _selectedSubject = val),
                                        ),
                                  const SizedBox(height: 16),

                                  const Text('Kelas Pengajaran', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: _selectedClass,
                                    decoration: _buildDropdownDecoration('Pilih Tingkatan Kelas'),
                                    items: ['Kelas 1', 'Kelas 2', 'Kelas 3', 'Kelas 4', 'Kelas 5', 'Kelas 6'].map((String val) {
                                      return DropdownMenuItem<String>(value: val, child: Text(val));
                                    }).toList(),
                                    onChanged: (val) => setState(() => _selectedClass = val),
                                  ),
                                  const SizedBox(height: 16),

                                  const Text('Bio Singkat Pengajar', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
                                  const SizedBox(height: 8),
                                  _buildTextField(controller: _bioController, hintText: 'ceritakan singkat profil mengajar Anda...'),
                                  const SizedBox(height: 16),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),

                      const Text('Password', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
                      const SizedBox(height: 8),
                      _buildTextField(controller: _passwordController, hintText: '••••••••', obscureText: true),
                      const SizedBox(height: 16),

                      const Text('Konfirmasi Password', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
                      const SizedBox(height: 8),
                      _buildTextField(controller: _confirmPasswordController, hintText: '••••••••', obscureText: true),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4D96FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Daftar Sekarang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: RichText(
                            text: const TextSpan(
                              text: 'Sudah punya akun? ',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                              children: [TextSpan(text: 'Masuk', style: TextStyle(color: Color(0xFF4D96FF), fontWeight: FontWeight.bold))],
                            ),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF4D96FF), width: 1.5)),
      ),
    );
  }

  InputDecoration _buildDropdownDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF4D96FF), width: 1.5)),
    );
  }
}