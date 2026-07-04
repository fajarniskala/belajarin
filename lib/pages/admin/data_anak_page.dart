import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart';

class DataAnakPage extends StatefulWidget {
  const DataAnakPage({Key? key}) : super(key: key);

  @override
  State<DataAnakPage> createState() => _DataAnakPageState();
}

class _DataAnakPageState extends State<DataAnakPage> {
  List<dynamic> _listAnak = [];
  bool _isLoading = true;

  // Controller Form Input Update Data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDataAnak();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ======================================================================
  // AMBIL DATA DARI BACKEND (READ)
  // ======================================================================
  Future<void> _fetchDataAnak() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dashboard/students'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _listAnak = jsonDecode(response.body)['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal terhubung ke server', Colors.red);
    }
  }

  // ======================================================================
  // FUNGSI PROSES MUTASI DATA (UPDATE / DELETE)
  // ======================================================================
  Future<void> _processStudentAction(
    String endpoint,
    Map<String, String> body,
    String successMsg,
  ) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/dashboard/$endpoint'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200) {
        _showSnackBar(successMsg, Colors.green);
        _fetchDataAnak(); // Auto refresh list ke UI terbaru
      } else {
        setState(() => _isLoading = false);
        _showSnackBar('Proses gagal dilakukan', Colors.orange);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Terjadi gangguan koneksi', Colors.red);
    }
  }

  // ======================================================================
  // POP-UP FORM DIALOG UBAH DATA ANAK / SISWA (UPDATE)
  // ======================================================================
  void _showEditStudentDialog(Map<String, dynamic> studentData) {
    _nameController.text = studentData['name'] ?? '';
    _emailController.text = studentData['email'] ?? '';
    _passwordController.text = studentData['password'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Ubah Data Anak (Siswa)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Akun',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password Akun',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (_nameController.text.isEmpty ||
                    _emailController.text.isEmpty ||
                    _passwordController.text.isEmpty) {
                  _showSnackBar('Semua field wajib diisi!', Colors.orange);
                  return;
                }
                Navigator.pop(context);

                _processStudentAction('updateStudent', {
                  'id': studentData['id'].toString(),
                  'name': _nameController.text.trim(),
                  'email': _emailController.text.trim(),
                  'password': _passwordController.text.trim(),
                }, 'Data siswa berhasil diperbarui!');
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ======================================================================
  // POP-UP FORM KONFIRMASI HAPUS DATA SISWA (DELETE)
  // ======================================================================
  void _showDeleteConfirmation(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Hapus Akun?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus akun siswa dari "$name"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _processStudentAction('deleteStudent', {
                'id': id,
              }, 'Akun siswa telah dihapus.');
            },
            child: const Text(
              'Ya, Hapus',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Data Anak (Siswa)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A90E2)),
            )
          : _listAnak.isEmpty
          ? const Center(
              child: Text(
                "Belum ada data siswa.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _listAnak.length,
              itemBuilder: (context, index) {
                final anak = _listAnak[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.01),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.cyan.shade50,
                      radius: 24,
                      child: Icon(
                        Icons.face_unlock_rounded,
                        color: Colors.cyan.shade600,
                      ),
                    ),
                    title: Text(
                      anak['name'] ?? 'Nama Siswa',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          "Email: ${anak['email'] ?? '-'}",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "Pass: ${anak['password'] ?? '-'}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 🌟 MENAMPILKAN NAMA ORANG TUA HASIL SELF JOIN
                        Text(
                          "Orang Tua: ${anak['parent_name'] ?? 'Belum Dikaitkan'}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Poin Belajar: ${anak['total_points'] ?? 0} 🌟",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.orange,
                            size: 22,
                          ),
                          onPressed: () => _showEditStudentDialog(anak),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                            size: 22,
                          ),
                          onPressed: () => _showDeleteConfirmation(
                            anak['id'].toString(),
                            anak['name'] ?? 'Siswa',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
