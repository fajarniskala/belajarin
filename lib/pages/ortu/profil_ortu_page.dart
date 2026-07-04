import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart';

class ProfilOrtuPage extends StatefulWidget {
  final int parentId;
  final String parentName;
  final String childName;
  final Map<String, dynamic> stats;

  const ProfilOrtuPage({
    Key? key,
    required this.parentId,
    required this.parentName,
    required this.childName,
    required this.stats,
  }) : super(key: key);

  @override
  State<ProfilOrtuPage> createState() => _ProfilOrtuPageState();
}

class _ProfilOrtuPageState extends State<ProfilOrtuPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Email dan Password wajib diisi!', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/ortucontroller/updateParentProfile'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'id': widget.parentId.toString(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        _showSnackBar('Profil berhasil diperbarui!', Colors.green);
        _passwordController.clear();
      } else {
        _showSnackBar('Gagal memperbarui profil', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan koneksi', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    // Menghitung total buku dari data stats kiriman dashboard
    int totalBuku =
        (int.tryParse(widget.stats['buku_selesai']?.toString() ?? '0') ?? 0) +
        (int.tryParse(widget.stats['sedang_dibaca']?.toString() ?? '0') ?? 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3),
      appBar: AppBar(
        title: const Text(
          'Profil Wali Murid',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: const Color(
          0xFF6C7EE1,
        ), // Tema ungu indigo sesuai dashboard ortu
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // AVATAR INDUK ORANG TUA
            CircleAvatar(
              radius: 45,
              backgroundColor: const Color(0xFFB15EFF),
              child: Text(
                widget.parentName.isNotEmpty
                    ? widget.parentName[0].toUpperCase()
                    : 'W',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.parentName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            Text(
              "Wali dari: ${widget.childName}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // TAMPILAN STATISTIK AKADEMIK ANAK SECARA RINGKAS
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Perkembangan Belajar ${widget.childName}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  '$totalBuku',
                  'Aset Buku',
                  Colors.blue.shade50,
                  Colors.blue.shade900,
                ),
                _buildStatCard(
                  '${widget.stats['poin_anak']}',
                  'Poin Anak',
                  Colors.amber.shade50,
                  Colors.amber.shade900,
                ),
                _buildStatCard(
                  '${widget.stats['total_durasi']}',
                  'Durasi Baca',
                  Colors.green.shade50,
                  Colors.green.shade900,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // FORM EDIT DATA EMAIL & PASSWORD UTK ORANG TUA
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pengaturan Kredensial Akun',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Baru Wali',
                prefixIcon: Icon(Icons.mail_outline_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Baru Wali',
                prefixIcon: Icon(Icons.lock_outline_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C7EE1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Simpan Kredensial Baru',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
