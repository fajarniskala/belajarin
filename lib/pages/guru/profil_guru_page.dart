import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api_config.dart';

class ProfilGuruPage extends StatefulWidget {
  final int guruId;
  final String guruName;
  final int myStudents;
  final int myModules;
  final int totalPoints;

  const ProfilGuruPage({
    Key? key,
    required this.guruId,
    required this.guruName,
    required this.myStudents,
    required this.myModules,
    required this.totalPoints,
  }) : super(key: key);

  @override
  State<ProfilGuruPage> createState() => _ProfilGuruPageState();
}

class _ProfilGuruPageState extends State<ProfilGuruPage> {
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
      _showSnackBar('Email dan Password baru wajib diisi!', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/gurucontroller/update-profile'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'id': widget.guruId.toString(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        _showSnackBar('Profil guru berhasil diperbarui!', Colors.green);
        _passwordController.clear();
      } else {
        _showSnackBar('Gagal memperbarui profil', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('Terjadi gangguan jaringan internet', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF20B2AA), // Warna tiska guru
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // AVATAR BULAT HURUF GURU
            CircleAvatar(
              radius: 45,
              backgroundColor: const Color(0xFF20B2AA).withOpacity(0.2),
              child: Text(
                widget.guruName.isNotEmpty ? widget.guruName[0].toUpperCase() : 'G',
                style: const TextStyle(color: Color(0xFF20B2AA), fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.guruName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            Text(
              "Tenaga Pendidik BelajarIn",
              style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            // KARTU BARIS STATISTIK KINERJA GURU
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('${widget.myStudents}', 'Siswa Saya', Colors.blue.shade50, Colors.blue.shade900),
                _buildStatCard('${widget.myModules}', 'Modul Saya', Colors.orange.shade50, Colors.orange.shade900),
                _buildStatCard('${widget.totalPoints}', 'Poin Rilis', Colors.green.shade50, Colors.green.shade900),
              ],
            ),
            const SizedBox(height: 32),

            // FORM EDIT AKSES KREDENSIAL
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pengaturan Akun Pengajar',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Baru Pengajar',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Baru Pengajar',
                prefixIcon: Icon(Icons.lock_outline_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
              ),
            ),
            const SizedBox(height: 28),

            // TOMBOL SIMPAN AKSI
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF20B2AA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Simpan Kredensial Baru',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color bgColor, Color textColor) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            textAlign: TextAlign.center, // Aman tanpa typo, bro!
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}