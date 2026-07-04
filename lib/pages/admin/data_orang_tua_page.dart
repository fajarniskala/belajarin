import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart';

class DataOrangTuaPage extends StatefulWidget {
  const DataOrangTuaPage({Key? key}) : super(key: key);

  @override
  State<DataOrangTuaPage> createState() => _DataOrangTuaPageState();
}

class _DataOrangTuaPageState extends State<DataOrangTuaPage> {
  List<dynamic> _listOrtu = [];
  bool _isLoading = true;

  // Controller Form Input Update Data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDataOrtu();
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
  Future<void> _fetchDataOrtu() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dashboard/parents'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _listOrtu = jsonDecode(response.body)['data'] ?? [];
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
  Future<void> _processOrtuAction(String endpoint, Map<String, String> body, String successMsg) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/dashboard/$endpoint'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200) {
        _showSnackBar(successMsg, Colors.green);
        _fetchDataOrtu(); // Auto refresh list
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
  // POP-UP FORM DIALOG UBAH DATA ORANG TUA (UPDATE)
  // ======================================================================
  void _showEditOrtuDialog(Map<String, dynamic> ortuData) {
    _nameController.text = ortuData['name'] ?? '';
    _emailController.text = ortuData['email'] ?? '';
    _passwordController.text = ortuData['password'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Ubah Data Orang Tua',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Akun', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password Akun', border: OutlineInputBorder()),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
                  _showSnackBar('Semua field wajib diisi!', Colors.orange);
                  return;
                }
                Navigator.pop(context);
                
                _processOrtuAction('updateParent', {
                  'id': ortuData['id'].toString(),
                  'name': _nameController.text.trim(),
                  'email': _emailController.text.trim(),
                  'password': _passwordController.text.trim(),
                }, 'Data orang tua berhasil diperbarui!');
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ======================================================================
  // POP-UP FORM KONFIRMASI HAPUS DATA (DELETE)
  // ======================================================================
  void _showDeleteConfirmation(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah kamu yakin ingin menghapus akun orang tua dari "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _processOrtuAction('deleteParent', {'id': id}, 'Akun orang tua telah dihapus.');
            },
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Data Orang Tua", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A90E2)))
          : _listOrtu.isEmpty
              ? const Center(child: Text("Belum ada data orang tua.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _listOrtu.length,
                  itemBuilder: (context, index) {
                    final ortu = _listOrtu[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 6, offset: const Offset(0, 2))
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade50,
                          radius: 24,
                          child: Icon(Icons.supervisor_account_rounded, color: Colors.green.shade600),
                        ),
                        title: Text(
                          ortu['name'] ?? 'Nama Orang Tua',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("Email: ${ortu['email'] ?? '-'}", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            Text("Pass: ${ortu['password'] ?? '-'}", style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tombol Edit
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.orange, size: 22),
                              onPressed: () => _showEditOrtuDialog(ortu),
                            ),
                            // Tombol Hapus
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
                              onPressed: () => _showDeleteConfirmation(ortu['id'].toString(), ortu['name'] ?? 'Orang Tua'),
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