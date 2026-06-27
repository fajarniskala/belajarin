import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart';

class TambahSiswaPage extends StatefulWidget {
  final int guruId; // Menerima ID Guru dari halaman Dashboard

  const TambahSiswaPage({super.key, required this.guruId});

  @override
  State<TambahSiswaPage> createState() => _TambahSiswaPageState();
}

class _TambahSiswaPageState extends State<TambahSiswaPage> {
  // Key untuk validasi Form
  final _formKey = GlobalKey<FormState>();

  // Controller untuk mengambil teks dari inputan
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variabel state
  String? _selectedParentId;
  bool _isLoading = false; // Loading untuk tombol simpan
  bool _isLoadingParents = true; // Loading untuk dropdown saat fetch data

  // List kosong yang akan diisi dari database MySQL
  List<Map<String, dynamic>> _listOrangTua = [];

  // PENTING: Sesuaikan base URL ini. 
  // Gunakan 'http://10.0.2.2:8080' jika di Emulator Android.
  // Gunakan 'http://localhost:8080' jika di Flutter Web.
  final String _baseUrl = '${ApiConfig.baseUrl}/gurucontroller';

  @override
  void initState() {
    super.initState();
    // Tarik data dropdown orang tua sesaat setelah halaman dibuka
    _fetchParents();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- FUNGSI GET: Mengambil Data Orang Tua dari CI4 ---
  Future<void> _fetchParents() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/parents'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> parentData = responseData['data'];

        if (mounted) {
          setState(() {
            _listOrangTua = parentData.map((p) => {
              "id": p['id'].toString(), 
              "name": "${p['name']} (${p['email']})" 
            }).toList();
            _isLoadingParents = false; 
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingParents = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat orang tua: ${response.statusCode}'), backgroundColor: Colors.orange),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingParents = false);
        print("Gagal mengambil data orang tua: $e");
      }
    }
  }

  // --- FUNGSI POST: Menyimpan Data Siswa Baru ke CI4 ---
  Future<void> _submitData() async {
    // Jalankan validasi form
    if (_formKey.currentState!.validate()) {
      if (_selectedParentId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap pilih Orang Tua terlebih dahulu!'), 
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Data JSON yang akan dikirim
      final dataSiswaBaru = {
        "name": _nameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "parent_id": _selectedParentId,
        "role": "child",
        "guru_id": widget.guruId.toString(),
      };

      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/add-student'), 
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(dataSiswaBaru),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil menyimpan data siswa!'), 
              backgroundColor: Colors.green,
            ),
          );
          
          // Kembali ke Dashboard Guru dengan nilai true
          Navigator.pop(context, true); 
          
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan data: ${response.statusCode}'), 
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan jaringan: $e'), 
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Tambah Data Siswa", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF20B2AA), 
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Informasi Siswa",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // 1. DROPDOWN PILIH ORANG TUA (Dinamis dari Database)
                const Text("Pilih Orang Tua", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: const Icon(Icons.family_restroom, color: Color(0xFF20B2AA)),
                  ),
                  hint: _isLoadingParents 
                      ? const Text("Memuat data orang tua...") 
                      : const Text("-- Pilih Data Orang Tua --"),
                  value: _selectedParentId,
                  items: _isLoadingParents 
                      ? [] 
                      : _listOrangTua.map((parent) {
                          return DropdownMenuItem<String>(
                            value: parent['id'],
                            child: Text(parent['name']),
                          );
                        }).toList(),
                  onChanged: (_isLoading || _isLoadingParents) ? null : (value) {
                    setState(() {
                      _selectedParentId = value;
                    });
                  },
                  validator: (value) => value == null ? 'Orang Tua wajib dipilih' : null,
                ),

                const SizedBox(height: 20),

                // 2. INPUT NAMA SISWA
                const Text("Nama Lengkap Siswa", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: "Masukkan nama siswa...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person, color: Color(0xFF20B2AA)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Nama tidak boleh kosong';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // 3. INPUT EMAIL SISWA
                const Text("Email Siswa (Opsional / Username)", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: "siswa@email.com",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.email, color: Color(0xFF20B2AA)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email wajib diisi';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // 4. INPUT PASSWORD
                const Text("Password Akun", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: "Masukkan password...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF20B2AA)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password wajib diisi';
                    if (value.length < 3) return 'Password terlalu pendek';
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // TOMBOL SIMPAN
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_isLoading || _isLoadingParents) ? null : _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading 
                        ? const SizedBox(
                            height: 24, 
                            width: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : const Text(
                            "Simpan Data Siswa",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}